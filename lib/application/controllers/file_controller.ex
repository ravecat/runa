defmodule RunaWeb.FileController do
  alias OAuth2.Response
  use RunaWeb, :controller
  use RunaWeb, :jsonapi
  use Runa.JSONAPI

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer

  alias Runa.Files
  alias Runa.Files.File
  alias RunaWeb.Schemas.Files, as: OperationSchemas
  alias RunaWeb.Serializers.File, as: Serializer

  plug RunaWeb.JSONAPI.Plug.ValidateRelationships, schema: File

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
        },
        required: true
      },
      responses: %{
        201 => %Response{
          description: "Resource created",
          content: %{
            "application/vnd.api+json" => %MediaType{
              schema: OperationSchemas.ShowResponse
            }
          }
        }
      }
    }
  end

  def create(conn, params) do
    with {:ok, data} <- Files.create(params) do
      conn |> put_status(201) |> render(data: data)
    end
  end
end
