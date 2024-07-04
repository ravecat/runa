defmodule RunaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use RunaWeb, :controller
      use RunaWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths,
    do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json, :jsonapi],
        layouts: [html: RunaWeb.Layouts]

      import Plug.Conn
      import RunaWeb.Gettext

      alias RunaWeb.FallbackController

      action_fallback FallbackController

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {RunaWeb.Layouts, :app}

      alias Phoenix.Template

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent
      alias Phoenix.Template

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      alias Phoenix.Template

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [
          get_csrf_token: 0,
          view_module: 1,
          view_template: 1
        ]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  def components do
    quote do
      import RunaWeb.Components.Icon
      import RunaWeb.Components.Avatar
      import RunaWeb.Components.Button
      import RunaWeb.Components.Flash
      import RunaWeb.Components.Info
      import RunaWeb.Components.Dropdown
      import RunaWeb.Components.Modal
      import RunaWeb.Components.Commands
      import RunaWeb.Components.Tab
      import RunaWeb.Components.Input
      import RunaWeb.Components.Label
      import RunaWeb.Components.Form
    end
  end

  def widgets do
    quote do
      alias RunaWeb.Components.Sidebar
    end
  end

  def openapi do
    quote do
      import OpenApiSpex.Operation,
        only: [parameter: 5, request_body: 4, response: 3]

      alias OpenApiSpex.JsonErrorResponse
      alias OpenApiSpex.MediaType
      alias OpenApiSpex.Operation
      alias OpenApiSpex.Reference
      alias OpenApiSpex.Response
      alias OpenApiSpex.Schema

      plug OpenApiSpex.Plug.CastAndValidate,
        render_error: RunaWeb.FallbackController

      def open_api_operation(action) do
        apply(__MODULE__, :"#{action}_operation", [])
      end
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Translation

      import RunaWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: RunaWeb.Endpoint,
        router: RunaWeb.Router,
        statics: RunaWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
