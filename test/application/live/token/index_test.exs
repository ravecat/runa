defmodule RunaWeb.Live.Token.IndexTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  import RunaWeb.Formatters

  @moduletag :tokens

  setup ctx do
    tokens = insert_list(3, :token, user: ctx.user)

    {:ok, tokens: tokens}
  end

  describe "Tokens view" do
    test "renders tokens titles", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      html =
        parent_view
        |> find_live_child("api_keys")
        |> render()

      for {token, index} <- Enum.with_index(ctx.tokens) do
        title =
          html
          |> Floki.find("table[aria-label='API keys'] tbody tr")
          |> Enum.at(index)
          |> Floki.find("td")
          |> Enum.at(0)
          |> Floki.text()
          |> String.trim()

        assert title == token.title
      end
    end

    test "renders token owner", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      html =
        parent_view
        |> find_live_child("api_keys")
        |> render()

      owner =
        html
        |> Floki.find("table[aria-label='API keys'] tbody tr")
        |> Enum.at(0)
        |> Floki.find("td")
        |> Enum.at(1)
        |> Floki.text()
        |> String.trim()

      assert owner =~ ctx.user.name
    end

    test "renders token created at", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      html =
        parent_view
        |> find_live_child("api_keys")
        |> render()

      for {token, index} <- Enum.with_index(ctx.tokens) do
        created_at =
          html
          |> Floki.find("table[aria-label='API keys'] tbody tr")
          |> Enum.at(index)
          |> Floki.find("td")
          |> Enum.at(2)
          |> Floki.text()
          |> String.trim()

        assert created_at == "#{format_datetime_to_view(token.inserted_at)}"
      end
    end

    test "renders token status", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      html =
        parent_view
        |> find_live_child("api_keys")
        |> render()

      for {token, index} <- Enum.with_index(ctx.tokens) do
        access =
          html
          |> Floki.find("table[aria-label='API keys'] tbody tr")
          |> Enum.at(index)
          |> Floki.find("td")
          |> Enum.at(4)
          |> Floki.text()
          |> String.trim()

        assert access == "#{token.access}"
      end
    end

    test "renders token delete button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      for token <- ctx.tokens do
        assert has_element?(
                 child_view,
                 "button[aria-label='Delete token'][data-token-id='#{token.id}']"
               )
      end
    end

    test "renders token update button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      for token <- ctx.tokens do
        assert has_element?(
                 child_view,
                 "button[aria-label='Update token'][data-token-id='#{token.id}']"
               )
      end
    end
  end

  describe "delete token modal" do
    test "renders by clicking delete token button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      refute has_element?(child_view, "[aria-modal='true'][role='dialog']")

      for token <- ctx.tokens do
        child_view
        |> element(
          "button[aria-label='Delete token'][data-token-id='#{token.id}']"
        )
        |> render_click()

        assert has_element?(child_view, "[aria-modal='true'][role='dialog']")
      end
    end

    test "deletes token by clicking delete button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      for token <- ctx.tokens do
        assert has_element?(child_view, "td", token.title)

        child_view
        |> element(
          "button[aria-label='Delete token'][data-token-id='#{token.id}']"
        )
        |> render_click()

        child_view
        |> element("button", "Delete")
        |> render_click()

        refute has_element?(child_view, "td", token.title)
      end
    end
  end

  describe "create token modal" do
    test "rendered by clicking create token button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      refute has_element?(child_view, "[aria-modal='true'][role='dialog']")

      child_view
      |> element("button[aria-label='Create token']")
      |> render_click()

      assert has_element?(child_view, "[aria-modal='true'][role='dialog']")
    end

    test "creates token ", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      title = Atom.to_string(ctx.test)

      child_view
      |> element("button[aria-label='Create token']")
      |> render_click()

      child_view
      |> element("form[aria-label='Token form']")
      |> render_submit(%{
        "token" => %{"access" => "read", "title" => title}
      })

      refute has_element?(child_view, "p", "can't be blank")
      refute has_element?(child_view, "p", "is invalid")

      assert has_element?(child_view, "td", title)
    end

    test "renders error when title is blank", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      child_view
      |> element("button[aria-label='Create token']")
      |> render_click()

      child_view
      |> element("form[aria-label='Token form']")
      |> render_submit(%{"token" => %{"access" => "read", "title" => ""}})

      assert has_element?(child_view, "p", "can't be blank")
    end

    test "renders error when access is invalid", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      title = Atom.to_string(ctx.test)

      child_view
      |> element("button[aria-label='Create token']")
      |> render_click()

      child_view
      |> element("form[aria-label='Token form']")
      |> render_submit(%{"token" => %{"access" => "invalid", "title" => title}})

      assert has_element?(child_view, "p", "is invalid")
    end
  end

  describe "update token modal" do
    test "renders by clicking update token button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      refute has_element?(child_view, "[aria-modal='true'][role='dialog']")

      for token <- ctx.tokens do
        child_view
        |> element(
          "button[aria-label='Update token'][data-token-id='#{token.id}']"
        )
        |> render_click()

        assert has_element?(child_view, "[aria-modal='true'][role='dialog']")
      end
    end

    test "updates token by clicking update button", ctx do
      {:ok, parent_view, _} =
        live(
          ctx.conn,
          ~p"/profile"
        )

      child_view =
        find_live_child(
          parent_view,
          "api_keys"
        )

      title = Atom.to_string(ctx.test)

      for token <- ctx.tokens do
        assert has_element?(child_view, "td", token.title)

        child_view
        |> element(
          "button[aria-label='Update token'][data-token-id='#{token.id}']"
        )
        |> render_click()

        child_view
        |> element("form[aria-label='Token form']")
        |> render_submit(%{"token" => %{"access" => "read", "title" => title}})

        refute has_element?(child_view, "td", token.title)

        assert has_element?(child_view, "td", title)
      end
    end
  end
end
