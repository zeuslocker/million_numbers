use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :million_numbers, MillionNumbersWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :million_numbers, MillionNumbers.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "million_numbers_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
