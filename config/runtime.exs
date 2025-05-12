import Config
import Dotenvy

env_dir_prefix = System.get_env("RELEASE_ROOT") || Path.expand("./envs")

source!([
  Path.absname(".env", env_dir_prefix),
  Path.absname(".#{config_env()}.env", env_dir_prefix),
  Path.absname(".#{config_env()}.overrides.env", env_dir_prefix),
  System.get_env()
])

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/runa start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :runa, RunaWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url = env!("DATABASE_URL", :string)

  maybe_ipv6 =
    if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :runa, Runa.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base = env!("SECRET_KEY_BASE", :string)

  host = env!("PHX_HOST", :string?, "localhost")
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :runa,
         :dns_cluster_query,
         System.get_env("DNS_CLUSTER_QUERY")

  config :runa, RunaWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :runa, RunaWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :runa, RunaWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  config :runa, Runa.Mailer,
    adapter: Swoosh.Adapters.Mailjet,
    api_key: env!("RUNA_MAILJET_API_KEY", :string?, ""),
    secret: env!("RUNA_MAILJET_SECRET", :string?, "")
end

if config_env() == :dev do
  config :runa, :session,
    dev_users:
      env!("RUNA_USER_EMAILS", fn emails ->
        emails |> String.split(",") |> Enum.map(&String.trim/1)
      end, [])
end

config :runa,
  app_domain: "#{Application.get_env(:runa, RunaWeb.Endpoint)[:url][:host]}",
  app_base_url:
    env!(
      "RUNA_APP_BASE_URL",
      :string?,
      "#{Application.get_env(:runa, RunaWeb.Endpoint)[:url][:scheme]}://#{Application.get_env(:runa, RunaWeb.Endpoint)[:url][:host]}:#{Application.get_env(:runa, RunaWeb.Endpoint)[:http][:port]}"
    )

config(:ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: env!("AUTH0_DOMAIN", :string?, ""),
  client_id: env!("AUTH0_CLIENT_ID", :string?, ""),
  client_secret: env!("AUTH0_CLIENT_SECRET", :string?, ""),
  redirect_uri: env!("AUTH0_REDIRECT_URI", :string?, "")
)

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: env!("GOOGLE_CLIENT_ID", :string?, ""),
  client_secret: env!("GOOGLE_CLIENT_SECRET", :string?, "")

config :ex_aws,
  access_key_id: [{:system, "RUNA_AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "RUNA_AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: {:system, "RUNA_AWS_REGION"}
