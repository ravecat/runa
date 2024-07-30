defmodule RunaWeb.QueryParser do
  @moduledoc """
  Query parser for JSONAPI requests
  """

  defmacro __using__(opts) do
    case Keyword.get(opts, :schema) do
      nil ->
        quote do
          plug JSONAPI.QueryParser, unquote(opts)
          plug unquote(__MODULE__)
        end

      schema ->
        quote do
          plug JSONAPI.QueryParser,
               Keyword.merge(unquote(opts),
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
               )

          plug unquote(__MODULE__)
        end
    end
  end

  def init(opts) do
    opts
  end

  def call(
        %{assigns: %{jsonapi_query: %{sort: nil} = jsonapi_query}} = conn,
        _opts
      ) do
    Plug.Conn.assign(conn, :jsonapi_query, %{jsonapi_query | sort: []})
  end

  def call(conn, _opts) do
    conn
  end
end
