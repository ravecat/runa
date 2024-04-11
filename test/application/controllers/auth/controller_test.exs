defmodule RunaWeb.Auth.Controller.Test do
  use RunaWeb.ConnCase

  @auth %Ueberauth.Auth{
    uid: "123",
    provider: :auth0,
    info: %{
      name: "John Doe",
      email: "john@mail.com",
      urls: %{avatar_url: "https://example.com/image.jpg"}
    }
  }

  describe "logout action" do
    test "logs out user and redirects to home page", %{conn: conn} do
      conn =
        conn
        |> put_session(:current_user, %{name: @auth.info.name, id: @auth.uid})
        |> get(~p"/logout")

      assert get_flash(conn, :info) == "You have been logged out!"
      assert redirected_to(conn) == ~p"/"

      conn = conn |> get(~p"/")

      refute conn |> get_session(:current_user)
    end
  end

  describe "callback action" do
    test "logs in on success auth", %{conn: conn} do
      conn =
        conn
        |> bypass_through(RunaWeb.Router, [:browser])
        |> assign(:ueberauth_auth, %{
          @auth
          | credentials: %{@auth.credentials | other: %{password: "pass"}}
        })
        |> get("/auth/auth0/callback")
        |> RunaWeb.Auth.Controller.callback(%{})

      assert get_flash(conn, :info) == "Successfully authenticated as #{@auth.info.name}."
      assert redirected_to(conn) == ~p"/profile"

      conn = conn |> get(~p"/")

      assert conn |> get_session(:current_user) == %{
               id: @auth.uid,
               name: @auth.info.name,
               avatar: @auth.info.urls.avatar_url
             }
    end

    test "reject on provider failure", %{conn: conn} do
      conn =
        conn
        |> bypass_through(RunaWeb.Router, [:browser])
        |> assign(:ueberauth_failure, "error")
        |> get("/auth/auth0/callback")
        |> RunaWeb.Auth.Controller.callback(%{})

      assert get_flash(conn, :error) == "Failed to authenticate."
      assert redirected_to(conn) == ~p"/"
    end
  end
end
