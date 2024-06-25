defmodule RunaWeb.TeamController do
  use RunaWeb, :controller
  use RunaWeb, :openapi

  alias Runa.Teams
  alias Runa.Teams.Team
  alias RunaWeb.FallbackController
  alias RunaWeb.Schemas

  action_fallback FallbackController

  @tags ["Teams"]

  def index_operation() do
    %Operation{
      tags: @tags,
      summary: "List teams",
      description: "List all teams related with user account",
      operationId: "getTeamList",
      responses: %{
        200 =>
          response(
            "Team list response",
            "application/vnd.api+json",
            Schemas.TeamsResponse
          ),
        422 => %Reference{"$ref": "#/components/responses/unprocessable_entity"}
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
            "Team response",
            "application/vnd.api+json",
            Schemas.TeamResponse
          ),
        404 =>
          response(
            "404",
            "application/vnd.api+json",
            Schemas.ErrorResponse
          ),
        422 =>
          response(
            "422",
            "application/vnd.api+json",
            Schemas.ErrorResponse
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
          Schemas.TeamPostRequest,
          required: true
        ),
      responses: %{
        201 =>
          response(
            "Team response",
            "application/vnd.api+json",
            Schemas.TeamResponse
          ),
        422 =>
          response(
            "Unprocessible entity",
            "application/vnd.api+json",
            Schemas.ErrorResponse
          )
      }
    }
  end

  def create(
        %{body_params: %Schemas.TeamPostRequest{data: %{attributes: attrs}}} =
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
      parameters: [
        parameter(:id, :path, :integer, "Team ID", example: 1, required: true)
      ],
      requestBody:
        request_body(
          "Team request",
          "application/vnd.api+json",
          Schemas.TeamPatchRequest,
          required: true
        ),
      responses: %{
        200 =>
          response(
            "Team response",
            "application/vnd.api+json",
            Schemas.TeamResponse
          ),
        422 =>
          response(
            "Unprocessible entity",
            "application/vnd.api+json",
            Schemas.ErrorResponse
          )
      }
    }
  end

  def update(
        %{body_params: %Schemas.TeamPatchRequest{data: %{attributes: attrs}}} =
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
      parameters: [
        parameter(:id, :path, :integer, "Team ID", example: 1, required: true)
      ],
      responses: %{
        200 => %Reference{"$ref": "#/components/responses/success_delete"}
      }
    }
  end

  def delete(conn, %{id: id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id),
         {:ok, %Team{}} <- Teams.delete_team(team) do
      conn
      |> put_status(200)
      |> render(:delete)
    end
  end
end
