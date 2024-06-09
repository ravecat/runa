defmodule RunaWeb.TeamController do
  use RunaWeb, :controller

  alias Runa.{Teams, Teams.Team}
  alias RunaWeb.FallbackController

  action_fallback FallbackController

  def index(conn, _params) do
    teams = Teams.get_teams()

    conn
    |> put_status(200)
    |> render(:index, data: teams)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id) do
      conn
      |> put_status(200)
      |> render(:show, data: team)
    end
  end

  def create(conn, attrs) do
    with {:ok, %Team{} = team} <- Teams.create_team(attrs) do
      conn
      |> put_status(201)
      |> render(:show, data: team)
    end
  end

  # def update(conn, %{"id" => id, "team" => team_params}) do
  #   team = Teams.get_team(id)

  #   with {:ok, %Team{} = team} <- Teams.update_team(team, team_params) do
  #     render(conn, :show, team: team)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   team = Teams.get_team(id)

  #   with {:ok, %Team{}} <- Teams.delete_team(team) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
