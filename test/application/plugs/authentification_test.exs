defmodule RunaWeb.Plug.AuthenticationTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias RunaWeb.Plug.Authentication

  @user %{id: "1", name: "John Doe"}

  test "redirects unauthenticated users", %{conn: conn} do
    conn =
      conn
      |> put_session(:current_user, nil)
      |> Authentication.call(nil)

    assert Flash.get(conn.assigns.flash, :error) ==
             "You can't access that page"

    assert redirected_to(conn) == ~p"/"
  end

  test "does not redirect authenticated users", %{
    conn: conn
  } do
    conn =
      conn
      |> put_session(:current_user, @user)
      |> Authentication.call(nil)

    assert conn.status != 302
  end
end
