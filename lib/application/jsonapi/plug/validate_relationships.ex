defmodule RunaWeb.JSONAPI.Plug.ValidateRelationships do
  @moduledoc """
  Plug for validating JSONAPI relationships.

  Checks if the relationships in the request are exist in the database.
  """

  alias Runa.Repo

  import Plug.Conn
  import Phoenix.Controller

  alias RunaWeb.ErrorJSON

  def init(opts), do: opts

  def call(
        %{
          path_params: %{"relationship" => relationship},
          body_params: %{"data" => relationships}
        } = conn,
        opts
      )
      when conn.method in ~w(PATCH PUT) do
    parent_schema = Keyword.fetch!(opts, :schema)

    child_schema =
      parent_schema.__schema__(:association, String.to_atom(relationship)).related

    ids = Enum.map(relationships, & &1["id"])

    case Repo.check_missing_resources(child_schema, ids) do
      [] ->
        conn

      missing_ids ->
        errors = [
          %{
            message:
              "#{relationship} contain unknown ids: #{Enum.join(missing_ids, ", ")}"
          }
        ]

        conn
        |> put_status(422)
        |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
        |> render(:error, errors: errors)
        |> halt()
    end
  end

  def call(conn, _opts) do
    conn
  end
end
