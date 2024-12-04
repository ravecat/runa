defmodule RunaWeb.Live.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  import RunaWeb.Formatters

  @moduletag :profile

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  test "authenticated user can see profile page", ctx do
    {:ok, _, html} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    assert html =~ ctx.user.name
  end

  describe "API keys block" do
    test "renders tokens list", ctx do
      {:ok, _, html} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      for token <- ctx.user.tokens do
        assert html =~ "#{token.id}"
      end
    end

    test "renders token owner", ctx do
      {:ok, _, html} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      assert html =~ ctx.user.name
    end

    test "renders token created at", ctx do
      {:ok, _, html} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      for token <- ctx.user.tokens do
        assert html =~ "#{format_datetime_to_view(token.inserted_at)}"
      end
    end

    test "renders token status", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      for token <- ctx.user.tokens do
        assert has_element?(
                 view,
                 "details[data-token-status-id=\"#{token.id}\"] summary",
                 "#{token.access}"
               )
      end
    end

    test "renders token delete button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      for token <- ctx.user.tokens do
        assert has_element?(
                 view,
                 "button[data-token-id=\"#{token.id}\"]"
               )
      end
    end
  end

  describe "delete token modal" do
    test "renders by clicking delete token button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      refute has_element?(view, "#modal")

      for token <- ctx.user.tokens do
        view
        |> element("button[data-token-id='#{token.id}']")
        |> render_click()

        assert has_element?(view, "#modal")
      end
    end

    test "deletes token by clicking delete button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      for token <- ctx.user.tokens do
        view
        |> element("[data-token-id='#{token.id}']")
        |> render_click()

        view
        |> element("button", "Delete")
        |> render_click()

        refute has_element?(view, "button[data-token-id='#{token.id}']")
      end
    end
  end

  describe "create token modal" do
    test "rendered by clicking create token button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      refute has_element?(view, "#modal")

      view
      |> element("button", "Create key")
      |> render_click()

      assert has_element?(view, "#modal")
    end

    test "creates token by clicking create button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      title = Atom.to_string(ctx.test)

      view
      |> element("button", "Create key")
      |> render_click()

      view
      |> element("form")
      |> render_submit(%{
        "token" => %{"access" => "read", "title" => title}
      })

      refute has_element?(view, "p", "can't be blank")
      refute has_element?(view, "p", "is invalid")

      assert has_element?(view, "td", title)
    end

    test "renders error when title is blank", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      view
      |> element("button", "Create key")
      |> render_click()

      view
      |> element("form")
      |> render_submit(%{"token" => %{"access" => "read", "title" => ""}})

      assert has_element?(view, "p", "can't be blank")
    end

    test "renders error when access is invalid", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      title = Atom.to_string(ctx.test)

      view
      |> element("button", "Create key")
      |> render_click()

      view
      |> element("form")
      |> render_submit(%{"token" => %{"access" => "invalid", "title" => title}})

      assert has_element?(view, "p", "is invalid")
    end
  end
end
