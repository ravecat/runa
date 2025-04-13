defmodule RunaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :runa

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_runa_key",
    signing_salt: "buKCuE47",
    same_site: "Lax"
  ]

  if sandbox = Application.compile_env(:runa, :sandbox, false) do
    plug Phoenix.Ecto.SQL.Sandbox, sandbox: sandbox
  end

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [:user_agent, session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :runa,
    gzip: false,
    only: RunaWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket",
           Phoenix.LiveReloader.Socket

    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :runa
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug :introspect
  plug RunaWeb.Router

  def introspect(conn, _opts) do
    req_cookies = conn.req_cookies["_runa_key"]

    if req_cookies do
      [_, payload, _] = String.split(req_cookies, ".", parts: 3)
      {:ok, encoded_cookie_data} = Base.url_decode64(payload, padding: false)

      dbg("==========ENDPOINT===========")
      IO.puts("path: #{conn.request_path}")
      IO.puts("req_cookies: #{req_cookies}")

      IO.puts(
        "encoded_cookie_data: #{inspect(:erlang.binary_to_term(encoded_cookie_data))} \n\n"
      )
    end

    conn
  end
end
