# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :million_numbers,
  ecto_repos: [MillionNumbers.Repo]

# Configures the endpoint
config :million_numbers, MillionNumbersWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TYt9RDhhu/ipB37o+S6cHuTkVcFWKsIcjy35B0RG7bhNLbJYU7vtbEfq8FzTZ3sv",
  render_errors: [view: MillionNumbersWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MillionNumbers.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
