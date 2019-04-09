# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ping, PingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "1CEyzMczm1kFuHqUJvNgq1Mi0kXZNsZUqR8Lon6N0w0jmMtuGfjSiRkSFgQRjJ6n",
  render_errors: [view: PingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Ping.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ping, Ping, max_players: 6

config :ping, Ping.Game,
  wall_size: 200,
  walls: 6

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
