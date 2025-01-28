defmodule RunaWeb.Router do
  use RunaWeb, :router

  require Ueberauth

  import RunaWeb.Plugs.Authentication, only: [authenticate: 2]

  @auth_path Application.compile_env(:ueberauth, Ueberauth)[:base_path]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RunaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug RunaWeb.Plugs.DevAuthentication
    plug RunaWeb.Plugs.Authentication
  end

  pipeline :openapi do
    plug OpenApiSpex.Plug.PutApiSpec, module: RunaWeb.APISpec
  end

  pipeline :api do
    plug :accepts, ["jsonapi"]
    plug OpenApiSpex.Plug.PutApiSpec, module: RunaWeb.APISpec
    plug RunaWeb.Plugs.APIKeyVerification
    plug JSONAPI.ContentTypeNegotiation
    plug JSONAPI.FormatRequired
    plug JSONAPI.ResponseContentType
    plug JSONAPI.Deserializer
    plug JSONAPI.UnderscoreParameters
  end

  scope "/" do
    pipe_through [:openapi]

    get "/api", OpenApiSpex.Plug.RenderSpec, []
    get "/openapi", OpenApiSpex.Plug.SwaggerUI, path: "/api"
  end

  scope "/" do
    pipe_through [:browser]

    get "/", RunaWeb.PageController, :home
  end

  scope @auth_path, RunaWeb do
    pipe_through :browser

    get "/:provider", SessionController, :request
    get "/:provider/callback", SessionController, :callback
    post "/:provider/callback", SessionController, :callback
    delete "/logout", SessionController, :logout
  end

  scope "/api", RunaWeb do
    pipe_through :api

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

  live_session :default, on_mount: [RunaWeb.SaveRequestUri] do
    scope "/profile", RunaWeb.Live do
      pipe_through [:browser, :authenticate]

      live "/", Profile
    end

    scope "/projects", RunaWeb.Live do
      pipe_through [:browser, :authenticate]

      live "/", Project.Index
      live "/:project_id", Project.Show
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
        metrics: RunaWeb.Telemetry
    end
  end
end
