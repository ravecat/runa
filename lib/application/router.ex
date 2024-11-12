defmodule RunaWeb.Router do
  use RunaWeb, :router

  require Ueberauth

  alias RunaWeb.APISpec
  alias RunaWeb.FileController
  alias RunaWeb.KeyController
  alias RunaWeb.LanguageController
  alias RunaWeb.Layouts
  alias RunaWeb.PageController
  alias RunaWeb.PageLive
  alias RunaWeb.Plugs.Authentication
  alias RunaWeb.ProjectController
  alias RunaWeb.SessionController
  alias RunaWeb.TeamController
  alias RunaWeb.Telemetry
  alias RunaWeb.TranslationController
  alias RunaWeb.Session

  @auth_path Application.compile_env(:ueberauth, Ueberauth)[:base_path]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug OpenApiSpex.Plug.PutApiSpec, module: APISpec
    plug :accepts, ["jsonapi"]

    plug JSONAPI.ContentTypeNegotiation
    plug JSONAPI.FormatRequired
    plug JSONAPI.ResponseContentType
    plug JSONAPI.Deserializer
    plug JSONAPI.UnderscoreParameters
  end

  scope "/api" do
    pipe_through :api

    get "/", OpenApiSpex.Plug.RenderSpec, []

    resources "/teams", TeamController,
      only: [:index, :show, :create, :update, :delete]

    resources "/teams/:id/relationships/:relationship", TeamController,
      only: [:show],
      singleton: true

    resources "/projects", ProjectController,
      only: [:index, :show, :create, :update, :delete]

    resources "/projects/:id/relationships/:relationship", ProjectController,
      only: [:show, :create, :update, :delete],
      singleton: true

    resources "/languages", LanguageController, only: [:index]
    resources "/files", FileController, only: [:create]

    resources "/keys", KeyController,
      only: [:create, :show, :index, :update, :delete]

    resources "/translations", TranslationController,
      only: [:create, :show, :update, :delete]
  end

  scope "/" do
    pipe_through :browser

    get "/openapi", OpenApiSpex.Plug.SwaggerUI, path: "/api"

    get "/", PageController, :home
  end

  scope @auth_path do
    pipe_through [:browser]

    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :callback
    post "/:provider/callback", SessionController, :callback
    delete "/logout", SessionController, :logout
  end

  live_session :default, on_mount: Session do
    scope "/profile" do
      pipe_through [:browser, Authentication]

      live "/", PageLive.Profile, :show
      live "/:id/edit", PageLive.Profile, :edit
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
