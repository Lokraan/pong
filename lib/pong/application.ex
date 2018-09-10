
# Dyanmic Supervisor

defmodule Pong.Application do
  use Application

  def start(_type, _args) do

    # List all child processes to be supervised
    children = [
      {DynamicSupervisor, strategy: :one_for_one, 
        name: Pong.LobbySupervisor}, # Module names are atoms.
      {DynamicSupervisor, strategy: :one_for_one,
        name: Pong.GameSupervisor},
      {Registry, keys: :unique, name: Pong.LobbyRegistry},
      {Registry, keys: :unique, name: Pong.GameRegistry},
      {Pong.Lobby, lobby_id: "lobby:find_lobby"},
      PongWeb.Endpoint,
      PongWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pong.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PongWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
