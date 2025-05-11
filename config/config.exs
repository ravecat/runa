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
  app_name: to_string(Mix.Project.config()[:app]),
  app_version: Mix.Project.config()[:version]

# Configures the endpoint
config :runa, RunaWeb.Endpoint,
  url: [host: "localhost", scheme: "http"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    accepts: ~w(html json jsonapi),
    formats: [html: RunaWeb.ErrorHTML, json: RunaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Runa.PubSub,
  live_view: [signing_salt: "jFW2IL4V"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure uberauth
config :ueberauth, Ueberauth,
  base_path: "/session",
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, []},
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ],
  json_library: Poison

# config :tailwind,
#   version: "3.4.3",
#   default: [args: ~w(
#       --config=tailwind.config.js
#       --input=css/app.css
#       --output=../priv/static/assets/app.css
#     ), cd: Path.expand("../assets", __DIR__)]

config :jsonapi,
  namespace: "/api",
  field_transformation: :underscore,
  remove_links: false,
  json_library: Jason

config :mime, :types, %{
  "application/vnd.api+json" => ["jsonapi"],
  "image/svg+xml" => ["svg"]
}

config :flop, repo: Runa.Repo

config :live_svelte,
  ssr: true

config :runa, Runa.Mailer, adapter: Swoosh.Adapters.Local

config :phoenix_template, :format_encoders, jsonapi: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
