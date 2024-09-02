defmodule RunaWeb.TeamController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Teams
  alias Runa.Teams.Team

  use RunaWeb.QueryParser,
    view: Serializers.Team,
    schema: Team

  @tags [Serializers.Team.type()]

  @spec index_operation() :: OpenApiSpex.Operation.t()
  def index_operation() do
    %Operation{
      tags: @tags,
      summary: "List teams",
      description: "List all teams related with user account",
      operationId: "getTeamList",
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.JSONAPI.Headers.content_type(),
            Schemas.Teams.IndexResponse
          )
      }
    }
  end

  def index(
        %{assigns: %{jsonapi_query: %{sort: sort, filter: filter, page: page}}} =
          conn,
        _params
      ) do
    with {:ok, {data, meta}} <-
           Teams.index(sort: sort, filter: filter, page: page) do
      conn
      |> put_status(200)
      |> render(:index,
        data: data,
        meta: meta
      )
    end
  end

  def show_operation() do
    %Operation{
      tags: @tags,
      summary: "Show team",
      description: "Show team details",
      operationId: "getTeam",
      parameters: [
        Schemas.JSONAPI.Parameters.path() | Schemas.JSONAPI.Parameters.query()
      ],
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.JSONAPI.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def show(conn, %{id: id}) do
    with {:ok, team = %Team{}} <- Teams.get(id) do
      conn
      |> put_status(200)
      |> render(:show, data: team)
    end
  end

  def create_operation() do
    %Operation{
      tags: @tags,
      summary: "Create team",
      description: "Create a new team",
      operationId: "createTeam",
      requestBody:
        request_body(
          "Team request",
          Schemas.JSONAPI.Headers.content_type(),
          Schemas.Teams.CreateBody,
          required: true
        ),
      responses: %{
        201 =>
          response(
            "201 OK",
            Schemas.JSONAPI.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def create(conn, _) do
    %{data: %{attributes: attrs}} = Map.get(conn, :body_params)

    with {:ok, %Team{} = team} <- Teams.create(attrs) do
      conn
      |> put_status(201)
      |> render(:show, data: team)
    end
  end

  def update_operation() do
    %Operation{
      tags: @tags,
      summary: "Update team",
      description: "Update team details",
      operationId: "updateTeam",
      parameters: [Schemas.JSONAPI.Parameters.path()],
      requestBody:
        request_body(
          "Team request",
          Schemas.JSONAPI.Headers.content_type(),
          Schemas.Teams.UpdateBody,
          required: true
        ),
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.JSONAPI.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def update(
        conn,
        %{id: id}
      ) do
    %{data: %{attributes: attrs}} = Map.get(conn, :body_params)

    with {:ok, team = %Team{}} <- Teams.get(id),
         {:ok, %Team{} = data} <- Teams.update(team, attrs) do
      render(conn, :show, data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: @tags,
      summary: "Delete team",
      description: "Delete team",
      operationId: "deleteTeam",
      parameters: [Schemas.JSONAPI.Parameters.path()],
      responses: %{
        204 => %Reference{"$ref": "#/components/responses/204"}
      }
    }
  end

  def delete(conn, %{id: id}) do
    with {:ok, team = %Team{}} <- Teams.get(id),
         {:ok, %Team{}} <- Teams.delete(team) do
      conn
      |> put_status(204)
      |> render(:delete)
    end
  end
end
