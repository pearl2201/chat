defmodule ChatSocketServer.RoomRegistry do
  use Agent

  def start_link(_args) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def get_server(server_id) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn x ->
        ChatSocketServer.RoomServer.get_room_id(x)
      end) == server_id
    end)
  end

  def add_server(server) do
    Agent.update(__MODULE__, fn [elem] -> [elem | server] end)
  end

  def room_list do
    Agent.get(__MODULE__, fn state ->
      Enum.map(state, fn x ->
        IO.inspect(x)
        ChatSocketServer.RoomServer.get_room_info(x) end)
    end)
  end
end
