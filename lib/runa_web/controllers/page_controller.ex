defmodule RunaWeb.PageController do
  use RunaWeb, :controller

  def home(conn, _) do
    case get_session(conn, :user_id) do
      nil -> maybe_put_development_users(conn) |> render(:home, layout: false)
      _ -> redirect(conn, to: ~p"/profile")
    end
  end

  def maybe_put_development_users(conn) do
    if Mix.env() == :dev do
      users =
        Application.get_env(:runa, :session)[:dev_users]
        |> Enum.map(&Runa.Accounts.get_by(email: to_string(&1)))

      assign(conn, :dev_users, users)
    else
      conn
    end
  end
end
