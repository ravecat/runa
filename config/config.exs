# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :runa,
  ecto_repos: [Runa.Repo],
  generators: [timestamp_type: :utc_datetime],
  permissions: %{
    owner: "owner",
    admin: "admin",
    editor: "editor",
    viewer: "viewer"
  }

# Configures the endpoint
config :runa, RunaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [
      html: RunaWeb.ErrorHTML,
      json: RunaWeb.ErrorJSON
    ],
    layout: false
  ],
  pubsub_server: Runa.PubSub,
  live_view: [signing_salt: "jFW2IL4V"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  runa: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*  --loader:.ttf=file),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure uberauth
config :ueberauth, Ueberauth,
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, []}
  ],
  json_library: Poison

config :tailwind,
  version: "3.4.3",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
