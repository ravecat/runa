defmodule RunaWeb.Router do
  use RunaWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RunaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RunaWeb.AuthPlug, :identify
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticate do
    plug RunaWeb.AuthPlug, :authenticate
  end

  scope "/auth", RunaWeb do
    pipe_through :browser

    get "/:provider", Auth.Controller, :request
    get "/:provider/callback", Auth.Controller, :callback
    post "/:provider/callback", Auth.Controller, :callback
  end

  live_session :default, on_mount: RunaWeb.UserData do
    scope "/", RunaWeb do
      pipe_through :browser

      get "/", PageController, :home
      get "/logout", Auth.Controller, :logout
    end

    scope "/profile", RunaWeb do
      pipe_through [:browser, :authenticate]

      live "/", PageLive.Profile, :show
      live "/:id/edit", PageLive.Profile, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", RunaWeb do
  #   pipe_through :api
  # end

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
        metrics: RunaWeb.Telemetry
    end
  end
end
