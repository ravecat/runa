defmodule RunaWeb.Plugs.QueryParser do
  @moduledoc """
  Query parser for JSONAPI requests
  """

  alias JSONAPI.Exceptions.InvalidQuery
  alias RunaWeb.ErrorJSON

  import Plug.Conn
  import Phoenix.Controller

  @behaviour Plug

  defmacro __using__(opts) do
    serializer = Keyword.fetch!(opts, :serializer)
    schema = Keyword.get(opts, :schema)

    quote do
      schema_opts =
        if unquote(schema) do
          [
            filter:
              unquote(schema)
              |> struct()
              |> Flop.Schema.filterable()
              |> Enum.map(&Atom.to_string/1),
            sort:
              unquote(schema)
              |> struct()
              |> Flop.Schema.sortable()
              |> Enum.map(&Atom.to_string/1)
          ]
        else
          []
        end

      plug unquote(__MODULE__),
           [view: unquote(serializer)] ++ unquote(opts) ++ schema_opts
    end
  end

  def init(opts) do
    JSONAPI.QueryParser.init(opts)
  end

  def call(conn, opts) do
    try do
      conn
      |> JSONAPI.QueryParser.call(opts)
      |> handle_sort_params(opts)
    rescue
      error in InvalidQuery ->
        conn
        |> put_status(400)
        |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
        |> render(:error, error: error)
        |> halt()
    end
  end

  defp handle_sort_params(
         %{assigns: %{jsonapi_query: %{sort: nil} = jsonapi_query}} = conn,
         _opts
       ) do
    assign(conn, :jsonapi_query, %{jsonapi_query | sort: []})
  end

  defp handle_sort_params(conn, _opts) do
    conn
  end
end
