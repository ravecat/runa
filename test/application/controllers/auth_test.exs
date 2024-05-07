defmodule RunaWeb.AuthControllerTest do
  use RunaWeb.ConnCase

  @moduletag :auth

  alias Runa.Teams

  import Runa.Auth.Fixtures
  import Runa.Permissions.Fixtures

  describe "logout action" do
    setup [:create_aux_success_auth]

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

  describe "callback action" do
    setup [:create_aux_success_auth, :create_aux_role]

    test "logs in on success auth", %{
      conn: conn,
      auth: auth
    } do
      conn =
        conn
        |> bypass_through(RunaWeb.Router, [:browser])
        |> assign(:ueberauth_auth, auth)
        |> get("/auth/auth0/callback")
        |> RunaWeb.AuthController.callback(%{})

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
      assert [] == Teams.get_teams()

      conn =
        conn
        |> bypass_through(RunaWeb.Router, [:browser])
        |> assign(:ueberauth_failure, "error")
        |> get("/auth/auth0/callback")
        |> RunaWeb.AuthController.callback(%{})

      assert [] = Teams.get_teams()

      assert get_flash(conn, :error) ==
               "Failed to authenticate."

      assert redirected_to(conn) == ~p"/"

      refute conn
             |> get(~p"/")
             |> get_session(:current_user)
    end
  end

  # describe "side effect creates default team" do
  #   setup [:create_aux_success_auth, :create_aux_role]

  #   test "on first successful sign up", %{
  #     conn: conn,
  #     auth: auth
  #   } do
  #     assert [] = Teams.get_teams()

  #     conn
  #     |> bypass_through(RunaWeb.Router, [:browser])
  #     |> assign(:ueberauth_auth, auth)
  #     |> get("/auth/auth0/callback")
  #     |> RunaWeb.AuthController.callback(%{})

  #     assert [%Runa.Teams.Team{} = team] = Teams.get_teams()
  #     assert team.title == "#{auth.info.name}'s Team"
  #   end
  # end

  # describe "side effect skips default team creation" do
  #   setup [:create_aux_success_auth, :create_aux_role]

  #   test "on second successful sign up", %{
  #     conn: conn,
  #     auth: auth
  #   } do
  #     assert [] = Teams.get_teams()

  #     conn
  #     |> bypass_through(RunaWeb.Router, [:browser])
  #     |> assign(:ueberauth_auth, auth)
  #     |> get("/auth/auth0/callback")
  #     |> RunaWeb.AuthController.callback(%{})

  #     assert [%Runa.Teams.Team{} = team] = Teams.get_teams()

  #     conn
  #     |> bypass_through(RunaWeb.Router, [:browser])
  #     |> assign(:ueberauth_auth, auth)
  #     |> get("/auth/auth0/callback")
  #     |> RunaWeb.AuthController.callback(%{})

  #     assert [%Runa.Teams.Team{} = ^team] = Teams.get_teams()
  #   end
  # end
end
