defmodule RunaWeb.Auth.Controller.Test do
  use RunaWeb.ConnCase

  @user_opts %{id: "1", name: "John Doe"}

  describe "logout action" do
    test "logs out user and redirects to home page", %{conn: conn} do
      conn =
        conn
        |> put_session(:current_user, @user_opts)
        |> get(~p"/logout")

      assert get_flash(conn, :info) == "You have been logged out!"
      assert redirected_to(conn) == ~p"/"

      conn = conn |> get(~p"/")

      refute conn |> get_session(:current_user)
    end
  end
end
