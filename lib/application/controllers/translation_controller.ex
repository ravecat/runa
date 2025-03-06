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
        generate_response_schemas(:create, %{
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

  def show_operation() do
    %Operation{
      tags: [@resource],
      summary: "Show of current resource",
      description: "Show of current resource",
      operationId: "getResource-#{@resource}",
      parameters: JSONAPI.Schemas.Parameters.path(),
      responses:
        generate_response_schemas(:show, %{
          200 => %Response{
            description: "Resource item",
            content: %{
              "application/vnd.api+json" => %MediaType{
                schema: OperationSchemas.ShowResponse
              }
            }
          }
        })
    }
  end

  def show(conn, %{"id" => id}) do
    with {:ok, data} <- Translations.get(id) do
      conn |> put_status(200) |> render(data: data)
    end
  end

  def update_operation() do
    %Operation{
      tags: [@resource],
      summary: "Update current resource",
      description: "Update current resource",
      operationId: "updateResource-#{@resource}",
      responses:
        generate_response_schemas(:update, %{
          200 => %Response{
            description: "Resource item",
            content: %{
              "application/vnd.api+json" => %MediaType{
                schema: OperationSchemas.ShowResponse
              }
            }
          }
        })
    }
  end

  def update(
        %{
          body_params: %{"data" => %{"attributes" => attrs}},
          path_params: %{"id" => id}
        } = conn,
        _
      ) do
    with {:ok, data} <- Translations.get(id),
         {:ok, data} <- Translations.update(data, attrs) do
      conn |> put_status(200) |> render(data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: [@resource],
      summary: "Delete current resource",
      description: "Delete current resource",
      operationId: "deleteResource-#{@resource}",
      responses: generate_response_schemas(:delete)
    }
  end

  def delete(%{path_params: %{"id" => id}} = conn, _) do
    with {:ok, data} <- Translations.get(id),
         {:ok, _} <- Translations.delete(data) do
      conn |> put_status(204) |> render(data: data)
    end
  end
end
