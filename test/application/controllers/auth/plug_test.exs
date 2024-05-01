defmodule RunaWeb.AuthPlug.Test do
  use RunaWeb.ConnCase

  @user %{id: "1", name: "John Doe"}

  test "redirects unauthenticated users", %{conn: conn} do
    conn =
      conn
      |> put_session(:current_user, nil)
      |> RunaWeb.AuthPlug.call(:authenticate)

    assert get_flash(conn, :error) ==
             "You can't access that page"

    assert redirected_to(conn) == ~p"/"
  end

  test "does not redirect authenticated users", %{
    conn: conn
  } do
    conn =
      conn
      |> put_session(:current_user, @user)
      |> RunaWeb.AuthPlug.call(:authenticate)

    assert conn.status != 302
  end

  test "puts current user to conn", %{conn: conn} do
    conn =
      conn
      |> put_session(:current_user, @user)
      |> RunaWeb.AuthPlug.call(:identify)

    assert conn.assigns[:current_user] == @user
  end
end
