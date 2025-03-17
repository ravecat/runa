defmodule RunaWeb.ProjectController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi
  use Runa.JSONAPI

  alias Runa.Projects
  alias Runa.Projects.Project
  alias RunaWeb.Schemas.Projects, as: OperationSchemas
  alias RunaWeb.Serializers.Project, as: Serializer

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer

  plug RunaWeb.JSONAPI.Plug.ValidateRelationships, schema: Project

  @resource Serializer.type()

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
           Projects.index(conn.assigns.scope, %{sort: sort, filter: filter, page: page}) do
      conn |> put_status(200) |> render(data: data, meta: meta)
    end
  end

  def show_operation() do
    %Operation{
      tags: [@resource],
      summary: "Show of current resource",
      description: "Show of current resource",
      operationId: "getResource-#{@resource}",
      parameters:
        JSONAPI.Schemas.Parameters.path() ++ JSONAPI.Schemas.Parameters.query(),
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
    with {:ok, data} <- Projects.get(conn.assigns.scope, id) do
      conn |> put_status(200) |> render(data: data)
    end
  end

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
          201 => %Response{
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

  def create(
        %{
          path_params: %{"relationship" => relationship, "id" => id},
          body_params: %{"data" => relationships}
        } = conn,
        _
      ) do
    with {:ok, schema} <- Projects.get(conn.assigns.scope, id),
        {:ok, data} <-
          create_relationships(
             schema,
             String.to_atom(relationship),
             relationships
           ) do
      conn |> put_status(201) |> render(data: data)
    end
  end

  def create(
        %{body_params: %{"data" => %{"relationships" => _, "attributes" => _}}} =
          conn,
        params
      ) do
    with {:ok, data} <- Projects.create(conn.assigns.scope, params) do
      conn |> put_status(201) |> render(data: data)
    end
  end

  def update_operation() do
    %Operation{
      tags: [@resource],
      summary: "Update resource",
      description: "Update resource",
      operationId: "updateResource-#{@resource}",
      parameters: JSONAPI.Schemas.Parameters.path(),
      requestBody: %RequestBody{
        description: "Resource request body",
        content: %{
          "application/vnd.api+json" => %MediaType{
            schema: OperationSchemas.UpdateBody
          }
        },
        required: true
      },
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
          path_params: %{"relationship" => relationship, "id" => id},
          body_params: %{"data" => relationships}
        } = conn,
        _
      ) do
    with {:ok, data} <- Projects.get(conn.assigns.scope, id),
         {:ok, data} <-
           update_relationships(
             data,
             String.to_atom(relationship),
             relationships
           ) do
      conn |> put_status(200) |> render(data: data)
    end
  end

  def update(
        %{
          body_params: %{"data" => %{"attributes" => attrs}},
          path_params: %{"id" => id}
        } = conn,
        _
      ) do
    with {:ok, data} <- Projects.get(conn.assigns.scope, id),
         {:ok, data} <- Projects.update(conn.assigns.scope, data, attrs) do
      conn |> put_status(200) |> render(data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: [@resource],
      summary: "Delete resource",
      description: "Delete resource",
      operationId: "deleteResource-#{@resource}",
      parameters: JSONAPI.Schemas.Parameters.path(),
      responses: generate_response_schemas(:delete)
    }
  end

  def delete(
        %{
          path_params: %{"relationship" => relationship, "id" => id},
          body_params: %{"data" => relationships}
        } = conn,
        _
      ) do
    with {:ok, schema} <- Projects.get(conn.assigns.scope, id),
         {:ok, data} <-
           delete_relationships(
             schema,
             String.to_atom(relationship),
             relationships
           ) do
      conn |> put_status(204) |> render(data: data)
    end
  end

  def delete(%{path_params: %{"id" => id}} = conn, _) do
    with {:ok, data} <- Projects.get(conn.assigns.scope, id),
         {:ok, _} <- Projects.delete(conn.assigns.scope, data) do
      conn |> put_status(204) |> render(:show)
    end
  end
end
