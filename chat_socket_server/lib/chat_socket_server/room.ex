defmodule ChatSocketServer.RoomServer do
  use GenServer

  def start_link({room_id, room_name, creator_id, creator_username}) do
    GenServer.start_link(__MODULE__, {room_id, room_name, creator_id, creator_username},
      name: {:global, "room:#{room_id}"}
    )
  end

  # Server (callbacks)

  @impl true
  def init({room_id, room_name, creator_id, creator_username}) do
    {:ok,
     %{
       room_id: room_id,
       room_name: room_name,
       members: [%{user_id: creator_id, username: creator_username}],
       messages: []
     }}
  end

  def get_room_id(pid) do
    GenServer.call(pid, :get_room_id)
  end

  def get_room_info(pid) do
    IO.puts("call get room info")
    GenServer.call(pid, :get_room_info)
  end

  def get_room_detail(pid) do
    IO.puts("call get room info")
    GenServer.call(pid, :get_room_detail)
  end

  def join_room(pid, member_id, member_username) do
    GenServer.call(pid, {:join_room, member_id, member_username})
  end

  def exit_room(pid, member_id) do
    GenServer.cast(pid, {:exit_room, member_id})
  end

  def send_message(pid, member_id, member_username,created_at, message_content) do
    GenServer.cast(pid, {:add_message, member_id, member_username, created_at,message_content})
  end

  @impl true
  def handle_call(:get_room_id, _from, state) do
    {:reply, state.room_id, state}
  end

  @impl true
  def handle_call(:get_room_info, _from, state) do
    IO.puts("handle_call")
    IO.inspect(state)

    ret = %{
      room_id: state.room_id,
      room_name: state.room_name
    }

    IO.inspect(ret)
    {:reply, ret, state}
  end

  @impl true
  def handle_call(:get_room_detail, _from, state) do
    IO.puts("handle_call")
    IO.inspect(state)

    ret = %{
      room_id: state.room_id,
      room_name: state.room_name,
      members: state.members,
      messages: state.messages
    }

    IO.inspect(ret)
    {:reply, ret, state}
  end

  @impl true
  def handle_cast({:exit_room, member_id}, state) do
    state =
      Map.put(state, :members, Enum.filter(state.members, fn x -> x.user_id != member_id end))

    {:reply, state}
  end

  @impl true
  def handle_cast({:join_room, member_id, member_username}, state) do
    state =
      Map.put(
        state,
        :members,
        state.members ++ [%{user_id: member_id, username: member_username}]
      )

    {:reply, state}
  end

  @impl true
  def handle_cast({:add_message, member_id, member_username, created_at,message_content}, state) do
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

    {:noreply, state}
  end
end
