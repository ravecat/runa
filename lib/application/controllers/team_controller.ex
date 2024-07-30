defmodule RunaWeb.TeamController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Teams
  alias Runa.Teams.Team

  use RunaWeb.QueryParser,
    view: Serializers.Team,
    schema: Team

  @tags [Serializers.Team.type()]

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
            Schemas.Headers.content_type(),
            Schemas.Teams.IndexResponse
          )
      }
    }
  end

  def index(
        %{assigns: %{jsonapi_query: %{sort: sort, filter: filter, page: page}}} =
          conn,
        _params
      )
      when map_size(page) > 0 do
    with {:ok, {data, %Flop.Meta{} = meta}} <-
           Teams.get_teams(sort: sort, filter: filter, page: page) do
      conn
      |> put_status(200)
      |> render(:index,
        data: data,
        page: meta
      )
    end
  end

  def index(
        %{assigns: %{jsonapi_query: %{sort: sort, filter: filter}}} = conn,
        _params
      ) do
    with data <- Teams.get_teams(sort: sort, filter: filter) do
      conn
      |> put_status(200)
      |> render(
        :index,
        data: data
      )
    end
  end

  def show_operation() do
    %Operation{
      tags: @tags,
      summary: "Show team",
      description: "Show team details",
      operationId: "getTeam",
      parameters: [Schemas.Params.path() | Schemas.Params.query()],
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def show(conn, %{id: id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id) do
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
          Schemas.Headers.content_type(),
          Schemas.Teams.CreateBody,
          required: true
        ),
      responses: %{
        201 =>
          response(
            "200 OK",
            Schemas.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def create(
        %{body_params: %Schemas.Teams.CreateBody{data: %{attributes: attrs}}} =
          conn,
        _
      ) do
    with {:ok, %Team{} = team} <- Teams.create_team(attrs) do
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
      parameters: [Schemas.Params.path()],
      requestBody:
        request_body(
          "Team request",
          Schemas.Headers.content_type(),
          Schemas.Teams.UpdateBody,
          required: true
        ),
      responses: %{
        200 =>
          response(
            "200 OK",
            Schemas.Headers.content_type(),
            Schemas.Teams.ShowResponse
          )
      }
    }
  end

  def update(
        %{body_params: %Schemas.Teams.UpdateBody{data: %{attributes: attrs}}} =
          conn,
        %{id: id}
      ) do
    with {:ok, team = %Team{}} <- Teams.get_team(id),
         {:ok, %Team{} = data} <- Teams.update_team(team, attrs) do
      render(conn, :show, data: data)
    end
  end

  def delete_operation() do
    %Operation{
      tags: @tags,
      summary: "Delete team",
      description: "Delete team",
      operationId: "deleteTeam",
      parameters: [Schemas.Params.path()],
      responses: %{
        204 => %Reference{"$ref": "#/components/responses/204"}
      }
    }
  end

  def delete(conn, %{id: id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id),
         {:ok, %Team{}} <- Teams.delete_team(team) do
      conn
      |> put_status(204)
      |> render(:delete)
    end
  end
end
