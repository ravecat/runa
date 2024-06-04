defmodule RunaWeb.TeamController do
  use RunaWeb, :controller

  alias Runa.Teams
  alias RunaWeb.FallbackController

  action_fallback FallbackController

  def index(conn, _params) do
    teams = Teams.get_teams()

    render(conn, :index, data: teams)
  end
end
