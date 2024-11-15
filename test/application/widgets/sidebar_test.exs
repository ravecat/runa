defmodule RunaWeb.Widgets.SidebarTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  @moduletag :sidebar

  alias RunaWeb.Components.Sidebar

  import Phoenix.LiveViewTest

  setup do
    user = insert(:user) |> Repo.preload(:teams)

    {:ok, user: user}
  end

  describe "sidebar (essential information)" do
    test "renders user avatar", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ ctx.user.avatar
    end

    test "renders user name", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ html_escape(ctx.user.name)
    end

    test "renders team title", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert Enum.any?(ctx.user.teams, fn team ->
               html =~ html_escape(team.title)
             end)
    end

    test "renders logout link", ctx do
      html = render_component(Sidebar, user: ctx.user, id: ctx.test)

      assert html =~ "href=\"#{~p"/session/logout"}\""
      assert html =~ "Logout"
    end
  end

  describe "sidebar (team list)" do
    test "renders create team tab", ctx do
      html = render_component(Sidebar, user: ctx.user, id: ctx.test)

      assert html =~ "Create team"
    end

    test "renders team list", ctx do
      html = render_component(Sidebar, user: ctx.user, id: ctx.test)

      assert Enum.any?(ctx.user.teams, fn team ->
               html =~ html_escape(team.title)
             end)
    end
  end
end
