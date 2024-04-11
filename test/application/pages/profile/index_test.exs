defmodule RunaWeb.UserLive.Test do
  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Runa.Accounts.Fixtures

  defp create_user(_) do
    user = user_fixture()

    %{user: user}
  end

  describe "authenticated user" do
    setup [:create_user]

    test "can see projects page", %{conn: conn, user: user} do
      {:ok, _show_live, html} =
        conn
        |> put_session(:current_user, user)
        |> live(~p"/profile")

      assert html =~ user.name
    end
  end

  describe "unauthenticated user" do
    test "can't see projects page", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/profile")
    end
  end
end
