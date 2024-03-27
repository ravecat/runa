import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :runa, Runa.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "runa_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :runa, RunaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "C3Vz504bPAE0Ik6A4nGbALDBrwNFGurw445+WHG8e7H9toKW8EfaXfhJN+KYmTm7",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :mix_test_watch,
  tasks: [
    "coveralls.multiple --type html --type json --type lcov",
    "credo"
  ],
  clear: true
