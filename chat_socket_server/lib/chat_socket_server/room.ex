defmodule ChatSocketServer.RoomServer do
  use GenServer
  alias Phoenix.PubSub

  def start_link({room_id, room_name, creator_id, creator_username}) do
    GenServer.start_link(__MODULE__, {room_id, room_name, creator_id, creator_username},
      name: {:global, "room:#{room_id}"}
    )
  end

  # Server (callbacks)

  @impl true
  def init({room_id, room_name, creator_id, creator_username}) do
    PubSub.subscribe(ChatSocketServer.PubSub, "user_leave")

    {:ok,
     %{
       room_id: room_id,
       room_name: room_name,
       creator_id: creator_id,
       creator_username: creator_username,
       members: [],
       messages: []
     }}
  end

  def get_room_id(pid) do
    GenServer.call(pid, :get_room_id)
  end

  def get_room_info(pid) do
    GenServer.call(pid, :get_room_info)
  end

  def get_room_detail(pid) do
    GenServer.call(pid, :get_room_detail)
  end

  def join_room(pid, member_id, member_username) do
    GenServer.cast(pid, {:join_room, member_id, member_username})
  end

  def exit_room(pid, member_id) do
    GenServer.cast(pid, {:exit_room, member_id})
  end

  def send_message(pid, member_id, member_username, created_at, message_content) do
    GenServer.cast(pid, {:add_message, member_id, member_username, created_at, message_content})
  end

  @impl true
  def handle_call(:get_room_id, _from, state) do
    {:reply, state.room_id, state}
  end

  @impl true
  def handle_call(:get_room_info, _from, state) do
    ret = %{
      room_id: state.room_id,
      room_name: state.room_name
    }

    {:reply, ret, state}
  end

  @impl true
  def handle_call(:get_room_detail, _from, state) do
    ret = %{
      room_id: state.room_id,
      room_name: state.room_name,
      members: state.members,
      messages: state.messages
    }

    {:reply, ret, state}
  end

  @impl true
  def handle_cast({:exit_room, member_id}, state) do
    state =
      Map.put(state, :members, Enum.filter(state.members, fn x -> x.user_id != member_id end))

    {:noreply, state}
  end

  @impl true
  def handle_cast({:join_room, member_id, member_username}, state) do
    state =
      if Enum.all?(state.members, fn x -> x.user_id != member_id end) do
        Map.put(
          state,
          :members,
          state.members ++ [%{user_id: member_id, username: member_username}]
        )
      else
        state
      end

    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_message, member_id, member_username, created_at, message_content}, state) do
    state =
      Map.put(
        state,
        :messages,
        state.messages ++
          [
            %{
              from_user_id: member_id,
              from_username: member_username,
              created_at: created_at,
              content: message_content
            }
          ]
      )

    IO.inspect(state)
    {:noreply, state}
  end

  @impl true
  def handle_info({_channel, pid, {:leave, presence}}, state) do
    {user_id, _} = Integer.parse(presence.user_id)
    GenServer.cast(pid, {:exit_room, user_id})
    {:noreply, state}
  end
end
