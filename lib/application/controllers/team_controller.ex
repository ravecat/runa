defmodule RunaWeb.TeamController do
  use RunaWeb, :controller

  alias Runa.{Teams, Teams.Team}
  alias RunaWeb.FallbackController

  action_fallback FallbackController

  def index(conn, _params) do
    teams = Teams.get_teams()

    render(conn, :index, data: teams)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, team = %Team{}} <- Teams.get_team(id) do
      render(conn, :show, data: team)
    end
  end
end
