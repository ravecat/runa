defmodule RunaWeb.PageController do
  use RunaWeb, :controller

  @env Mix.env()

  def home(conn, _) do
    case get_session(conn, :user_id) do
      nil -> maybe_put_development_users(conn) |> render(:home, layout: false)
      _ -> redirect(conn, to: ~p"/profile")
    end
  end

  def maybe_put_development_users(conn) do
    users = if @env == :dev do
      Application.get_env(:runa, :session)[:dev_users]
      |> Enum.map(&Runa.Accounts.get_by(email: to_string(&1)))
    end

    assign(conn, :dev_users, users)
  end
end
