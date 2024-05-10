defmodule ChatSocketServer.RoomServer do
  use GenServer

  def start_link({room_id, room_name}) do
    GenServer.start_link(__MODULE__, {room_id, room_name}, name: {:global, "room:#{room_id}"})
  end

  # Server (callbacks)

  @impl true
  def init({room_id, room_name}) do
    {:ok, %{room_id: room_id, room_name: room_name, members: [], messages: []}}
  end

  def get_room_id(pid) do
    GenServer.call(pid, :get_room_id)
  end

  def get_room_info(pid) do
    IO.puts("call get room info")
    GenServer.call(pid, :get_room_info)
  end

  @impl true
  def handle_call(:get_room_id, _from, state) do
    {:reply, state["room_id"], state}
  end

  @impl true
  def handle_call(:get_room_info, _from, state) do
    IO.puts("on call")
    {:reply, %{room_id: state["room_id"], room_name: state["room_name"]}, state}
  end
end
