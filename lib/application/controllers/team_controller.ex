defmodule RunaWeb.TeamController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Teams
  alias Runa.Teams.Team
  alias RunaWeb.FallbackController
  alias RunaWeb.Schemas.Teams, as: Schemas
  alias RunaWeb.TeamSerializer, as: Serializer

  action_fallback FallbackController

  @tags [Serializer.type()]

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
            "application/vnd.api+json",
            Schemas.IndexResponse
          )
      }
    }
  end

  def index(conn, _params) do
    teams = Teams.get_teams()

    conn
    |> put_status(200)
    |> render(:index, data: teams)
  end

  def show_operation() do
    %Operation{
      tags: @tags,
      summary: "Show team",
      description: "Show team details",
      operationId: "getTeam",
      parameters: [
        parameter(:id, :path, :integer, "Team ID", example: 1, required: true)
      ],
      responses: %{
        200 =>
          response(
            "200 OK",
            "application/vnd.api+json",
            Schemas.ShowResponse
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
          "application/vnd.api+json",
          Schemas.CreateBody,
          required: true
        ),
      responses: %{
        201 =>
          response(
            "200 OK",
            "application/vnd.api+json",
            Schemas.ShowResponse
          )
      }
    }
  end

  def create(
        %{body_params: %Schemas.CreateBody{data: %{attributes: attrs}}} = conn,
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
      parameters: [
        parameter(:id, :path, :integer, "Team ID", example: 1, required: true)
      ],
      requestBody:
        request_body(
          "Team request",
          "application/vnd.api+json",
          Schemas.UpdateBody,
          required: true
        ),
      responses: %{
        200 =>
          response(
            "200 OK",
            "application/vnd.api+json",
            Schemas.ShowResponse
          )
      }
    }
  end

  def update(
        %{body_params: %Schemas.UpdateBody{data: %{attributes: attrs}}} = conn,
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
      parameters: [
        parameter(:id, :path, :integer, "Team ID", example: 1, required: true)
      ],
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
