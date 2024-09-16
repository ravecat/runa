defmodule RunaWeb.LanguageController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi

  alias Runa.Languages, as: Context
  alias RunaWeb.Schemas.Languages, as: OperationSchemas
  alias RunaWeb.Serializers.Language, as: Serializer

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer

  @resource Serializer.type()

  def index_operation() do
    %Operation{
      tags: [@resource],
      summary: "List of current resources",
      description: "List of current resources",
      operationId: "getResourcesList-#{@resource}",
      responses: %{
        200 =>
          response(
            "200 OK",
            JSONAPI.Schemas.Headers.content_type(),
            OperationSchemas.IndexResponse
          )
      }
    }
  end

  def index(
        %{
          assigns: %{jsonapi_query: %{sort: sort, filter: filter, page: page}}
        } = conn,
        _params
      ) do
    with {:ok, {data, meta}} <-
           Context.index(sort: sort, filter: filter, page: page) do
      conn |> put_status(200) |> render(:index, data: data, meta: meta)
    end
  end
end
