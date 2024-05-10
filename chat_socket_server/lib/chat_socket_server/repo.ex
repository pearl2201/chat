defmodule ChatSocketServer.Repo do
  use Ecto.Repo,
    otp_app: :chat_socket_server,
    adapter: Ecto.Adapters.Postgres
end
