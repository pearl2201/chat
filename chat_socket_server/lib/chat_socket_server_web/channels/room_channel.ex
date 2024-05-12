defmodule ChatSocketServerWeb.RoomChannel do
  use ChatSocketServerWeb, :channel

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def join("room:" <> private_room_id, _params, socket) do
    private_room_id = Integer.parse(private_room_id)
    server = ChatSocketServer.RoomRegistry.get_server(private_room_id)
    IO.inspect(server)
    ChatSocketServer.RoomServer.join_room(server, socket.assigns.user_id, socket.assigns.username)

    socket = socket.assign(:room_id, private_room_id)

    broadcast(socket, "user_join", %{
      user_id: socket.assigns.user_id,
      username: socket.assigns.username
    })

    push(socket, "room_detail", ChatSocketServer.RoomServer.get_room_detail(server))
    IO.inspect(server)
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", _payload, socket) do
    payload = %{}
    {:reply, {:ok, payload}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("send_message", payload, socket) do
    payload = %{
      from_user_id: socket.assigns.user_id,
      from_username: socket.assigns.username,
      created_at: DateTime.utc_now(),
      content: payload.message_content
    }

    broadcast(socket, "new_message", payload)
    server = ChatSocketServer.RoomRegistry.get_server(socket.assigns.room_id)
    ChatSocketServer.RoomServer.join_room(server, socket.assigns.user_id, socket.assigns.username)

    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in(evt, payload, socket) do
    IO.inspect(evt)
    IO.inspect(payload)

    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_info(
        %{topic: topic, event: "phx_leave"} = message,
        %{topic: topic, serializer: serializer, transport_pid: transport_pid, assigns: assigns} =
          socket
      ) do
    IO.inspect("on leave")
    send(transport_pid, serializer.encode!(build_leave_reply(message)))

    if Map.has_key?(assigns, :room_id) do
      server = ChatSocketServer.RoomRegistry.get_server(assigns.room_id)

      ChatSocketServer.RoomServer.exit_room(
        server,
        socket.assigns.user_id
      )
    end

    {:stop, {:shutdown, :left}, socket}
  end

  def handle_info(evt, socket) do
    IO.inspect(evt)
    {:noreply, socket}
  end

  def build_leave_reply(_message) do
    %{}
  end

    # Add authorization logic here as required.
    defp authorized?(_payload) do
      true
    end
end
