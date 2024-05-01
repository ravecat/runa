defmodule RunaWeb.PageController do
  use RunaWeb, :controller

  def home(conn, _params) do
    render(conn, "home.html", layout: false)
  end
end
