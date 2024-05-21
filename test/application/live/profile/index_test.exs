defmodule RunaWeb.PageLive.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase

  @moduletag :profile

  import Phoenix.LiveViewTest

  import Runa.{
    AccountsFixtures,
    TeamsFixtures,
    TeamRolesFixtures,
    RolesFixtures
  }

  describe "authenticated user" do
    setup [
      :create_aux_role,
      :create_aux_user,
      :create_aux_team
    ]

    test "can see projects page", %{
      conn: conn,
      user: user,
      team: team,
      role: role
    } do
      create_aux_team_role(%{
        team_id: team.id,
        user_id: user.id,
        role_id: role.id
      })

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
