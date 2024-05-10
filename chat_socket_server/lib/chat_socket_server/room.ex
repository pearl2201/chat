defmodule ChatSocketServer.RoomServer do
  use GenServer

  def start_link(room_id, room_name) do
    GenServer.start_link(__MODULE__, {room_id, room_name}, name: {:global, "room:#{room_id}"})
  end

  # Server (callbacks)

  @impl true
  def init({room_id, room_name}) do
    {:ok, %{room_id: room_id, members: [], messages: []}}
  end

  def get_room_id(pid) do
    GenServer.call(pid, :get_room_id)
  end

  @impl true
  def handle_call(:get_room_id, _from, state) do
    {:reply, state["room_id"], state}
  end
end
