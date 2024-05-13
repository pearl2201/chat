defmodule ChatSocketServerWeb.LobbyChannel do
  use ChatSocketServerWeb, :channel

  @impl true
  def join("lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, %{user_id: socket.assigns.user_id}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("get_roomlist", _payload, socket) do
    payload = ChatSocketServer.RoomRegistry.room_list()

    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("create_room", %{"room_name" => room_name}, socket) do
    room_id = ChatSocketServer.UserIdCounter.increment()

    child_spec =
      {ChatSocketServer.RoomServer,
       {room_id, room_name, socket.assigns.user_id, socket.assigns.username}}

    gen_server =
      case DynamicSupervisor.start_child(ChatSocketServer.DynamicSupervisor, child_spec) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
        error -> raise error
      end

    ChatSocketServer.RoomRegistry.add_server(gen_server)
    broadcast(socket, "add_roomlist", %{"room_id" => room_id, "room_name" => room_name})
    {:reply, {:ok, %{"room_id" => room_id, "room_name" => room_name}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  @impl true
  def handle_info(
        %{topic: topic, event: "phx_leave"} = message,
        %{topic: topic, serializer: serializer, transport_pid: transport_pid, assigns: assigns} =
          socket
      ) do
    IO.puts("on leave")

    {:stop, {:shutdown, :left}, socket}
  end
end
