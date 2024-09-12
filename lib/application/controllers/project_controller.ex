defmodule RunaWeb.ProjectController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi

  alias Runa.Projects, as: Context
  alias RunaWeb.Schemas.Projects, as: OperationSchemas
  alias RunaWeb.Serializers.Project, as: Serializer

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

  def show_operation() do
    %Operation{
      tags: [@resource],
      summary: "Show of current resource",
      description: "Show of current resource",
      operationId: "getResource-#{@resource}",
      parameters: [
        JSONAPI.Schemas.Parameters.path() | JSONAPI.Schemas.Parameters.query()
      ],
      responses: %{
        200 =>
        response(
            "200 OK",
            JSONAPI.Schemas.Headers.content_type(),
            OperationSchemas.ShowResponse
          )
      }
    }
  end

  def show(conn, %{id: id}) do
    with {:ok, data} <- Context.get(id) do
      conn |> put_status(200) |> render(:show, data: data)
    end
  end

  def create_operation() do
    %Operation{
      tags: [@resource],
      summary: "Create new resource",
      description: "Create new resource",
      operationId: "createResource-#{@resource}",
      requestBody:
        request_body(
          "Resource request body",
          JSONAPI.Schemas.Headers.content_type(),
          OperationSchemas.CreateBody,
          required: true
        ),
      responses: %{
        201 =>
          response(
            "201 OK",
            JSONAPI.Schemas.Headers.content_type(),
            OperationSchemas.ShowResponse
          )
      }
    }
  end

  def create(%{private: %{open_api_spex: open_api_spex}} = conn, _) do
    with %{data: %{attributes: attrs, relationships: relationships}} =
           Map.get(open_api_spex, :body_params),
         %{"team" => %{data: %{id: team_id}}} = relationships,
         dataset = Map.put(attrs, :team_id, team_id),
         {:ok, data} <- Context.create(dataset) do
      conn |> put_status(201) |> render(:show, data: data)
    end
  end

  def update_operation() do
    %Operation{
      tags: [@resource],
      summary: "Update resource",
      description: "Update resource",
      operationId: "updateResource-#{@resource}",
      parameters: [JSONAPI.Schemas.Parameters.path()],
      requestBody:
        request_body(
          "Resource request body",
          JSONAPI.Schemas.Headers.content_type(),
          OperationSchemas.UpdateBody,
          required: true
        ),
      responses: %{
        200 =>
          response(
            "200 OK",
            JSONAPI.Schemas.Headers.content_type(),
            OperationSchemas.ShowResponse
          )
      }
    }
  end

  def update(conn, %{id: id}) do
    %{data: %{attributes: attrs}} = Map.get(conn, :body_params)

    with {:ok, data} <- Context.get(id),
         {:ok, data} <- Context.update(data, attrs) do
      render(conn, :show, data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: [@resource],
      summary: "Delete resource",
      description: "Delete resource",
      operationId: "deleteResource-#{@resource}",
      parameters: [JSONAPI.Schemas.Parameters.path()],
      responses: %{204 => %Reference{"$ref": "#/components/responses/204"}}
    }
  end

  def delete(conn, %{id: id}) do
    with {:ok, data} <- Context.get(id),
         {:ok, _} <- Context.delete(data) do
      conn |> put_status(204) |> render(:delete)
    end
  end
end
