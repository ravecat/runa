defmodule RunaWeb.Plugs.QueryParser do
  @moduledoc """
  Query parser for JSONAPI requests
  """

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

      plug JSONAPI.QueryParser,
           [view: unquote(serializer)] ++ unquote(opts) ++ schema_opts

      plug unquote(__MODULE__)
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
