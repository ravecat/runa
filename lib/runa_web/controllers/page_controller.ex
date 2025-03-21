defmodule RunaWeb.PageController do
  use RunaWeb, :controller

  def home(conn, _params) do
    case conn.assigns[:current_user] do
      nil -> render(conn, :home, layout: false)
      _ -> redirect(conn, to: ~p"/profile")
    end
  end
end
