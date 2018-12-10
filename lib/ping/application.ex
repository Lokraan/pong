defmodule Ping.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, 
        name: Ping.LobbySupervisor},
      {DynamicSupervisor, strategy: :one_for_one,
        name: Ping.GameSupervisor},
      {Registry, keys: :unique, name: Ping.LobbyRegistry},
      {Registry, keys: :unique, name: Ping.GameRegistry},
      # Start the endpoint when the application starts
      PingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ping.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
