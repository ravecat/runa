defmodule RunaWeb.Widgets.Sidebar.Test do
  @moduledoc false
  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest

  alias RunaWeb.Components.Sidebar

  import Phoenix.LiveViewTest
  import Runa.Accounts.Fixtures
  import Runa.Teams.Fixtures

  describe "Sidebar" do
    setup [:create_aux_user, :create_aux_team]

    test "renders menu items", %{user: user, team: team} do
      html = render_component(Sidebar, %{user: user, active_team: team})

      assert html =~ "Profile"
      assert html =~ "Projects"
      assert html =~ "Team"
      assert html =~ "Logout"
    end

    test "renders wokrspace info", %{user: user, team: team} do
      html = render_component(Sidebar, %{user: user, active_team: team})

      assert html =~ "#{user.name}"
      assert html =~ "owner"
      assert html =~ "#{team.title}"
    end
  end
end
