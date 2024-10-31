defmodule RunaWeb.KeyController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi
  use Runa.JSONAPI

  alias Runa.Keys
  alias Runa.Keys.Key
  alias RunaWeb.Schemas.Keys, as: OperationSchemas
  alias RunaWeb.Serializers.Key, as: Serializer

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer

  plug RunaWeb.JSONAPI.Plug.ValidateRelationships, schema: Key

  @resource Serializer.type()

  def create_operation() do
    %Operation{
      tags: [@resource],
      summary: "Create new resource",
      description: "Create new resource",
      operationId: "createResource-#{@resource}",
      requestBody: %RequestBody{
        description: "Resource request body",
        content: %{
          "application/vnd.api+json" => %MediaType{
            schema: OperationSchemas.CreateBody
          }
        }
      },
      responses:
        generate_responses(%{
          200 => %Response{
            description: "Resource list",
            content: %{
              "application/vnd.api+json" => %MediaType{
                schema: OperationSchemas.ShowResponse
              }
            }
          }
        })
    }
  end

  def create(conn, params) do
    with {:ok, data} <- Keys.create(params) do
      conn |> put_status(201) |> render(data: data)
    end
  end
end
