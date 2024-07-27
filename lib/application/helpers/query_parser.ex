defmodule RunaWeb.QueryParser do
  @moduledoc """
  Query parser for JSONAPI requests
  """

  defmacro __using__(opts) do
    case Keyword.get(opts, :schema) do
      nil ->
        quote do
          plug JSONAPI.QueryParser, unquote(opts)
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
        end
    end
  end
end
