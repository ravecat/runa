defmodule RunaWeb.Router do
  use RunaWeb, :router

  require Ueberauth

  alias RunaWeb.Layouts
  alias RunaWeb.Plug.Authentication
  alias RunaWeb.Telemetry
  alias RunaWeb.UserData

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Authentication
  end

  pipeline :api do
    plug :accepts, ["jsonapi"]
    plug JSONAPI.EnsureSpec
    plug JSONAPI.Deserializer
    plug JSONAPI.UnderscoreParameters
  end

  scope "/api", RunaWeb do
    pipe_through :api

    resources "/teams", TeamController
  end

  scope "/", RunaWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/logout", AuthController, :logout
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback
  end

  live_session :default, on_mount: UserData do
    scope "/profile", RunaWeb.PageLive do
      pipe_through [:browser, :auth]

      live "/", Profile, :show
      live "/:id/edit", Profile, :edit
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:runa, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: Telemetry
    end
  end
end
