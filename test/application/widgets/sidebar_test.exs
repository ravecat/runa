defmodule RunaWeb.Widgets.SidebarTest do
  @moduledoc false

  use RunaWeb.ConnCase

  @moduletag :sidebar

  alias RunaWeb.Components.Sidebar
  alias Runa.Repo

  import Phoenix.LiveViewTest

  import Runa.AccountsFixtures

  describe "sidebar" do
    setup do
      user = create_aux_user() |> Repo.preload(:teams)

      %{user: user}
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
