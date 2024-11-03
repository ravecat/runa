defmodule RunaWeb.TranslationController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi
  use Runa.JSONAPI

  alias Runa.Translations
  alias Runa.Translations.Translation
  alias RunaWeb.Schemas.Translations, as: OperationSchemas
  alias RunaWeb.Serializers.Translation, as: Serializer

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer

  plug RunaWeb.JSONAPI.Plug.ValidateRelationships, schema: Translation

  @resource Serializer.type()

  def create_operation() do
    %Operation{
      tags: [@resource],
      summary: "Create new resource",
      description: "Create new resource",
      operationId: "createResource-#{@resource}",
      requestBody: %RequestBody{
        description: "Request body",
        content: %{
          "application/vnd.api+json" => %MediaType{
            schema: OperationSchemas.CreateBody
          }
        }
      },
      responses:
        generate_responses(%{
          200 => %Response{
            description: "Translation created",
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
    with {:ok, data} <- Translations.create(params) do
      conn |> put_status(201) |> render(data: data)
    end
  end
end
