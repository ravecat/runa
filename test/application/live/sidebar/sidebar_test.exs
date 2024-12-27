defmodule RunaWeb.Live.SidebarTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias RunaWeb.Live.Sidebar

  @moduletag :sidebar

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  describe "sidebar (essential information)" do
    test "renders user avatar", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "[aria-label='User avatar']")
    end

    test "renders user name", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "[aria-label='Current user']", ctx.user.name)
    end

    test "renders logout link", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "[aria-label='Logout']")
    end

    test "renders profile link", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "[aria-label='Navigate to profile']")
    end

    test "renders projects link", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(view, "[aria-label='Navigate to projects']")
    end

    test "renders current team role", ctx do
      team = insert(:team)

      contributor = insert(:contributor, team: team, user: ctx.user)

      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(
               view,
               "[aria-label='Current team role']",
               "#{contributor.role}"
             )
    end

    test "renders current team name", ctx do
      team = insert(:team)

      insert(:contributor, team: team, user: ctx.user)

      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      assert has_element?(
               view,
               "[aria-label='Current team']",
               team.title
             )
    end

    test "hides current team name if no team is existed", ctx do
      {:ok, view, _} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      refute has_element?(
               view,
               "[aria-label='Current team']"
             )
    end
  end

  describe "sidebar (user dropdown)" do
    test "renders team list", ctx do
      teams = insert_list(2, :team)

      for team <- teams do
        insert(:contributor, team: team, user: ctx.user)
      end

      {:ok, _, html} =
        live_isolated(ctx.conn, Sidebar, session: %{"user_id" => ctx.user.id})

      for team <- teams do
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

      refute has_element?(view, "[aria-modal='true'][role='dialog']")

      assert view
             |> element("button", "Create team")
             |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
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
