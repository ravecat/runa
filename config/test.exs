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
  secret_key_base:
    "C3Vz504bPAE0Ik6A4nGbALDBrwNFGurw445+WHG8e7H9toKW8EfaXfhJN+KYmTm7",
  session_options: [
    store: :cookie,
    key: "_runa_key_test",
    signing_salt: "buKCuE47",
    same_site: "Lax"
  ],
  server: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :mix_test_watch,
  tasks: ["test", "test.static"],
  clear: true,
  extra_extensions: [".svelte", ".ts", ".js"],
  exclude: [
    ~r/\.#/,
    ~r{priv/repo/migrations},
    ~r{priv/static/assets},
    ~r{priv/svelte}
  ]

config :wallaby,
  otp_app: :runa,
  screenshot_on_failure: true,
  chromedriver: [
    path: "assets/node_modules/chromedriver/bin/chromedriver",
    headless: true
  ]

config :runa, :sandbox, Ecto.Adapters.SQL.Sandbox
