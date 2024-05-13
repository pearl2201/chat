defmodule ChatSocketServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {ChatSocketServer.UserIdCounter,0 },
      ChatSocketServer.RoomRegistry,
      # Start the Telemetry supervisor
      ChatSocketServerWeb.Telemetry,
      # Start the Ecto repository
      ChatSocketServer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, [name: ChatSocketServer.PubSub,adapter: Phoenix.PubSub.PG2]},
      ChatSocketServerWeb.Presence,
      # Start Finch
      {Finch, name: ChatSocketServer.Finch},
      # Start the Endpoint (http/https)
      ChatSocketServerWeb.Endpoint,
      {DynamicSupervisor, strategy: :one_for_one, name: ChatSocketServer.DynamicSupervisor}
      # Start a worker by calling: ChatSocketServer.Worker.start_link(arg)
      # {ChatSocketServer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatSocketServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatSocketServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
