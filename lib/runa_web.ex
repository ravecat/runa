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

      import RunaWeb.APISpec
      import Plug.Conn
      import RunaWeb.Gettext

      alias RunaWeb.Schemas

      action_fallback RunaWeb.FallbackController

      unquote(verified_routes())
    end
  end

  def jsonapi do
    quote do
      import OpenApiSpex.Operation,
        only: [parameter: 5, request_body: 4, response: 3]

      alias OpenApiSpex.MediaType
      alias OpenApiSpex.Operation
      alias OpenApiSpex.Parameter
      alias OpenApiSpex.Reference
      alias OpenApiSpex.RequestBody
      alias OpenApiSpex.Response
      alias OpenApiSpex.Schema

      plug OpenApiSpex.Plug.CastAndValidate,
        render_error: RunaWeb.FallbackController,
        replace_params: false

      alias RunaWeb.JSONAPI

      def open_api_operation(action) do
        apply(__MODULE__, :"#{action}_operation", [])
      end
    end
  end

  def live_view do
    quote do
      alias Runa.PubSub
      alias Runa.Repo

      import Ecto.Changeset

      use Phoenix.LiveView,
        layout: {RunaWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      alias Phoenix.LiveView.JS

      import RunaWeb.Components.Commands
      import Tails

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      alias Runa.PubSub

      import Ecto
      import Ecto.Changeset

      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      alias Phoenix.Template

      import Phoenix.Controller,
        only: [
          get_csrf_token: 0,
          view_module: 1,
          view_template: 1
        ]

      unquote(html_helpers())
    end
  end

  def serializer do
    quote do
      use JSONAPI.View, paginator: RunaWeb.JSONAPI.LinksConstructor

      alias RunaWeb.Formatters
      alias RunaWeb.Serializers

      def inserted_at_timestamp(data, _conn) do
        Formatters.format_datetime_to_timestamp(data.inserted_at)
      end

      def updated_at_timestamp(data, _conn) do
        Formatters.format_datetime_to_timestamp(data.updated_at)
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

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
