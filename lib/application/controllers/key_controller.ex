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
        generate_response_schemas(:create, %{
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
    with {:ok, data} <- Keys.get(id) do
      conn |> put_status(200) |> render(data: data)
    end
  end

  def index_operation() do
    %Operation{
      tags: [@resource],
      summary: "List of current resources",
      description: "List of current resources",
      operationId: "getResourcesList-#{@resource}",
      responses:
        generate_response_schemas(:index, %{
          200 => %Response{
            description: "Resource list",
            content: %{
              "application/vnd.api+json" => %MediaType{
                schema: OperationSchemas.IndexResponse
              }
            }
          }
        })
    }
  end

  def index(
        %{assigns: %{jsonapi_query: %{sort: sort, filter: filter, page: page}}} =
          conn,
        _params
      ) do
    with {:ok, {data, meta}} <-
           Keys.index(%{sort: sort, filter: filter, page: page}) do
      conn |> put_status(200) |> render(data: data, meta: meta)
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
    with {:ok, data} <- Keys.get(id),
         {:ok, data} <- Keys.update(data, attrs) do
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
    with {:ok, data} <- Keys.get(id),
         {:ok, _} <- Keys.delete(data) do
      conn |> put_status(204) |> render(data: data)
    end
  end
end
