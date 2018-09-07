
defmodule Pong.Application do
  use Application

  def start(_type, args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Pong.Registry},
      {PongWeb.Game, game_id: args.game_id},
      {PongWeb.Lobby, lobby_id: args.lobby_id},
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
