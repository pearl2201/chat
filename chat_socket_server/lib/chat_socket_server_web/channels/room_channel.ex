defmodule ChatSocketServerWeb.RoomChannel do
  use ChatSocketServerWeb, :channel
  alias ChatSocketServerWeb.Presence
  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, %{user_id: socket.assigns.user_id}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def join("room:" <> private_room_id, _params, socket) do
    {private_room_id, _} = Integer.parse(private_room_id)
    server = ChatSocketServer.RoomRegistry.get_server(private_room_id)

    ChatSocketServer.RoomServer.join_room(server, socket.assigns.user_id, socket.assigns.username)

    socket = assign(socket, :room_id, private_room_id)

    send(self(), :after_join)

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
      content: payload["message_content"]
    }

    broadcast(socket, "new_message", payload)
    server = ChatSocketServer.RoomRegistry.get_server(socket.assigns.room_id)

    ChatSocketServer.RoomServer.send_message(
      server,
      socket.assigns.user_id,
      socket.assigns.username,
      payload.created_at,
      payload.content
    )

    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in(evt, payload, socket) do
    IO.inspect(evt)
    IO.inspect(payload)

    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_info(:after_join, socket) do
    server = ChatSocketServer.RoomRegistry.get_server(socket.assigns.room_id)

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        user_id: socket.assigns.user_id,
        username: socket.assigns.username,
        room_id: socket.assigns.room_id,
        online_at: inspect(System.system_time(:second))
      })

    broadcast(socket, "user_join", %{
      user_id: socket.assigns.user_id,
      username: socket.assigns.username
    })

    push(socket, "room_detail", ChatSocketServer.RoomServer.get_room_detail(server))

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{topic: topic, event: "phx_leave"} = message,
        %{topic: topic, serializer: serializer, transport_pid: transport_pid, assigns: assigns} =
          socket
      ) do
    IO.puts("on leave")
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

  def handle_info(%{topic: "user:0", payload: state}, socket) do
    IO.puts("HANDLE BROADCAST FOR #{state[:status]}")
    {:noreply, assign(socket, state)}
  end

  def handle_info(evt, socket) do
    IO.inspect("handle_info")
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

  # @impl true
  # def handle_out("user_join", payload, socket) do
  #   IO.inspect(payload)
  #   IO.inspect(socket)

  #   if socket.assigns.user_id != payload.user_id do
  #     push(socket, "user_join", payload)
  #   end

  #   {:noreply, socket}
  # end
end
