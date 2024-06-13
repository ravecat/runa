defmodule RunaWeb.Widgets.SidebarTest do
  @moduledoc false

  use RunaWeb.ConnCase

  @moduletag :sidebar
  @roles Application.compile_env(:runa, :permissions)

  alias RunaWeb.Components.Sidebar

  import Phoenix.LiveViewTest
  import Runa.Factory

  describe "sidebar" do
    setup do
      insert(:role, title: @roles[:owner])
      teams = insert_list(2, :team)
      user = insert(:user, teams: teams)

      {:ok, user: user}
    end

    test "renders menu items", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ "Profile"
      assert html =~ "Projects"
      assert html =~ "Team"
      assert html =~ "Logout"
    end

    test "renders wokrspace info", ctx do
      team = ctx.user.teams |> List.first()

      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ html_escape(ctx.user.name)
      assert html =~ html_escape(team.title)
    end

    test "renders team list", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ "Create team"
    end
  end
end
