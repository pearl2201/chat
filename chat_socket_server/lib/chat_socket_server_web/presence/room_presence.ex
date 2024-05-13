defmodule ChatSocketServerWeb.Presence do
  use Phoenix.Presence,
    otp_app: :chat_socket_server,
    pubsub_server: ChatSocketServer.PubSub

  def init(_opts) do
    # user-land state
    {:ok, %{}}
  end

  def handle_metas(_topic, %{joins: _joins, leaves: leaves}, _presences, state) do
    # fetch existing presence information for the joined users and broadcast the
    # event to all subscribers
    # for {user_id, _presence} <- joins do
    #   user_data = %{user_id: user_id, metas: Map.fetch!(presences, user_id)}
    #   msg = {ChatSocketServerWeb.RoomChannel, {:join, user_data}}
    #   Phoenix.PubSub.local_broadcast(ChatSocketServer.PubSub, topic, msg)
    # end

    # fetch existing presence information for the left users and broadcast the
    # event to all subscribers

    for {user_id, presence} <- leaves do
      metas = presence.metas
      user_data = %{user_id: user_id, metas: metas}
      room_id = Enum.at(metas, 0).room_id
      server = ChatSocketServer.RoomRegistry.get_server(room_id)
      msg = {ChatSocketServerWeb.RoomChannel, server, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(ChatSocketServer.PubSub, "user_leave", msg)
      ChatSocketServerWeb.Endpoint.broadcast("room:#{room_id}", "user_leave", %{user_id: user_id})
    end

    {:ok, state}
  end
end
