defmodule RunaWeb.TeamController do
  use RunaWeb, :controller
  use RunaWeb, :jsonapi

  alias Runa.Teams, as: Context
  alias Runa.Teams.Team, as: Schema

  alias RunaWeb.Schemas.Teams, as: OperationSchemas
  alias RunaWeb.Serializers.Team, as: Serializer

  use RunaWeb.Plugs.QueryParser,
    serializer: Serializer,
    schema: Schema

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

  def show(conn, %{"id" => id}) do
    with {:ok, data} <- Context.get(id) do
      conn |> put_status(200) |> render(data: data)
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

  def create(
        %{
          body_params: %{
            "data" => %{"attributes" => attrs}
          }
        } = conn,
        _
      ) do
    with {:ok, data} <- Context.create(attrs) do
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

  def update(
        %{
          body_params: %{
            "data" => %{"attributes" => attrs}
          },
          path_params: %{"id" => id}
        } = conn,
        _
      ) do
    with {:ok, data} <- Context.get(id),
         {:ok, data} <- Context.update(data, attrs) do
      render(conn, data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: [@resource],
      summary: "Delete resource",
      description: "Delete resource",
      operationId: "deleteResource-#{@resource}",
      parameters: JSONAPI.Schemas.Parameters.path(),
      responses: %{204 => %Reference{"$ref": "#/components/responses/204"}}
    }
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, data} <- Context.get(id),
         {:ok, _} <- Context.delete(data) do
      conn |> put_status(204) |> render(:show)
    end
  end
end
