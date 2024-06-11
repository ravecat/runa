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

  def update(conn, %{"id" => id} = attrs) do
    with {:ok, team = %Team{}} <- Teams.get_team(id),
         {:ok, %Team{} = data} <- Teams.update_team(team, attrs) do
      render(conn, :show, data: data)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id),
         {:ok, %Team{}} <- Teams.delete_team(team) do
      conn
      |> put_status(204)
      |> render(:delete)
    end
  end
end
