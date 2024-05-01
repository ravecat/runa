defmodule RunaWeb.Widgets.SidebarTest do
  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RunaWeb.Components.Sidebar

  import Runa.Accounts.Fixtures
  import Runa.Teams.Fixtures
  import Runa.Permissions.Fixtures

  describe "Sidebar" do
    setup [
      :create_aux_user,
      :create_aux_team,
      :create_aux_role,
      :create_aux_team_role
    ]

    test "renders menu items", %{user: user, test: test} do
      user = user |> Runa.Repo.preload(:teams)

      html = render_component(Sidebar, %{user: user, id: test})

      assert html =~ "Profile"
      assert html =~ "Projects"
      assert html =~ "Team"
      assert html =~ "Logout"
    end

    test "renders wokrspace info", %{user: user, team: team, test: test} do
      user = user |> Runa.Repo.preload(:teams)

      html = render_component(Sidebar, %{user: user, id: test})

      assert html =~ "#{user.name}"
      assert html =~ "#{team.title}"
    end

    test "renders team list", %{user: user, team: team, test: test} do
      user = user |> Runa.Repo.preload(:teams)

      html = render_component(Sidebar, %{user: user, id: test})

      assert html =~ "Create team"
    end
  end
end
