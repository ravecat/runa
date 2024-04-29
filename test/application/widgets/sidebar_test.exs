defmodule RunaWeb.Widgets.Sidebar.Test do
  @moduledoc false
  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RunaWeb.Components.Sidebar

  import Phoenix.LiveViewTest
  import Runa.Accounts.Fixtures
  import Runa.Teams.Fixtures
  import Runa.Permissions.Fixtures

  describe "Sidebar" do
    setup [:create_aux_user, :create_aux_team, :create_aux_role, :create_aux_team_role]

    test "renders menu items", %{user: user} do
      user = user |> Runa.Repo.preload(:teams)

      html = render_component(Sidebar, %{user: user})

      assert html =~ "Profile"
      assert html =~ "Projects"
      assert html =~ "Team"
      assert html =~ "Logout"
    end

    test "renders wokrspace info", %{user: user, team: team} do
      user = user |> Runa.Repo.preload(:teams)

      html = render_component(Sidebar, %{user: user})

      assert html =~ "#{user.name}"
      assert html =~ "#{team.title}"
    end
  end
end
