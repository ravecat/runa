defmodule RunaWeb.AuthControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase

  @moduletag :auth

  alias RunaWeb.AuthController
  alias RunaWeb.Router

  setup do
    insert(:role)

    auth = build(:auth)

    {:ok, auth: auth}
  end

  describe "auth module" do
    test "logs out user and redirects to home page", %{
      conn: conn,
      auth: auth
    } do
      conn =
        conn
        |> put_session(:current_user, %{
          name: auth.info.name,
          id: auth.uid
        })
        |> get(~p"/logout")

      assert get_flash(conn, :info) ==
               "You have been logged out!"

      assert redirected_to(conn) == ~p"/"

      refute conn
             |> get(~p"/")
             |> get_session(:current_user)
    end
  end

  test "logs in on success auth",
       %{
         conn: conn,
         auth: auth
       } do
    conn =
      conn
      |> bypass_through(Router, [:browser])
      |> assign(:ueberauth_auth, auth)
      |> get(~p"/auth/auth0/callback")
      |> AuthController.callback(%{})

    assert get_flash(conn, :info) ==
             "Successfully authenticated as #{auth.info.name}."

    assert redirected_to(conn) == ~p"/profile"

    assert conn
           |> get(~p"/")
           |> get_session(:current_user) == %{
             uid: auth.uid,
             email: auth.info.email
           }
  end

  test "reject on provider failure", %{conn: conn} do
    conn =
      conn
      |> bypass_through(Router, [:browser])
      |> assign(:ueberauth_failure, %Ueberauth.Failure{})
      |> get(~p"/auth/auth0/callback")
      |> AuthController.callback(%{})

    assert get_flash(conn, :error) ==
             "Failed to authenticate."

    assert redirected_to(conn) == ~p"/"

    refute conn
           |> get(~p"/")
           |> get_session(:current_user)
  end
end
