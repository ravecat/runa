defmodule RunaWeb.Auth.Controller.Test do
  use RunaWeb.ConnCase

  def create_auth(_),
    do: %{
      auth: %Ueberauth.Auth{
        uid: "123",
        provider: :auth0,
        info: %{
          name: "John Doe",
          email: "john@mail.com",
          urls: %{avatar_url: "https://example.com/image.jpg"},
          nickname: "johndoe"
        }
      }
    }

  describe "logout action" do
    setup [:create_auth]

    test "logs out user and redirects to home page", %{conn: conn, auth: auth} do
      conn =
        conn
        |> put_session(:current_user, %{name: auth.info.name, id: auth.uid})
        |> get(~p"/logout")

      assert get_flash(conn, :info) == "You have been logged out!"
      assert redirected_to(conn) == ~p"/"

      refute conn |> get(~p"/") |> get_session(:current_user)
    end
  end

  describe "callback action" do
    setup [:create_auth]

    test "logs in on success auth", %{conn: conn, auth: auth} do
      conn =
        conn
        |> bypass_through(RunaWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> get("/auth/auth0/callback")
        |> RunaWeb.Auth.Controller.callback(%{})

      assert get_flash(conn, :info) == "Successfully authenticated as #{auth.info.name}."
      assert redirected_to(conn) == ~p"/profile"

      assert conn |> get(~p"/") |> get_session(:current_user) == %{
               uid: auth.uid,
               name: auth.info.name,
               avatar: auth.info.urls.avatar_url,
               nickname: auth.info.nickname
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

      refute conn |> get(~p"/") |> get_session(:current_user)
    end
  end
end
