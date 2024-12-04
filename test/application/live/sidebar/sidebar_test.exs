defmodule RunaWeb.Live.SidebarTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias RunaWeb.Live.Sidebar

  @moduletag :sidebar

  setup do
    user = insert(:user) |> Repo.preload([:teams])

    {:ok, user: user}
  end

  describe "sidebar (essential information)" do
    test "renders user avatar", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "img[alt='avatar']")
    end

    test "renders user name", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "span", ctx.user.name)
    end

    test "renders logout link", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "a", "Logout")
    end
  end

  describe "sidebar (user dropdown)" do
    test "renders team list", ctx do
      {:ok, _, html} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      for team <- ctx.user.teams do
        assert html =~ team.title
      end
    end

    test "renders create team button", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "button", "Create team")
    end

    test "shows modal when clicking create team button", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      refute has_element?(view, "#modal")

      assert view
             |> element("button", "Create team")
             |> render_click()

      assert has_element?(view, "#modal")
    end
  end

  describe "sidebar (create team modal)" do
    test "creates team when form is valid", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      team = Atom.to_string(ctx.test)

      assert view
             |> element("button", "Create team")
             |> render_click()

      view
      |> element("form")
      |> render_submit(%{"team" => %{"title" => team}})

      assert render_async(view) =~ team
    end

    test "renders error when form is invalid", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert view
             |> element("button", "Create team")
             |> render_click()

      view
      |> element("form")
      |> render_submit(%{"team" => %{"title" => ""}})

      assert has_element?(view, "p", "can't be blank")
    end
  end
end
