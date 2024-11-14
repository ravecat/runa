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

  describe "sidebar" do
    test "renders wokrspace info", ctx do
      team = List.first(ctx.user.teams)

      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ html_escape(ctx.user.name)
      assert html =~ html_escape(team.title)
    end

    test "renders team list", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ "Create team"
    end

    test "renders logout link", ctx do
      html = render_component(Sidebar, %{user: ctx.user, id: ctx.test})

      assert html =~ "href=\"#{~p"/session/logout"}\""
      assert html =~ "Logout"
    end
  end
end
