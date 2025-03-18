defmodule RunaWeb.Live.Token.IndexTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  import RunaWeb.Formatters

  @moduletag :tokens

  setup ctx do
    [token | _] = tokens = insert_list(3, :token, user: ctx.user)

    {:ok, tokens: tokens, token: token}
  end

  describe "Tokens view" do
    test "renders tokens titles", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      html = render(view)

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
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      html = render(view)

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
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      html = render(view)

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
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      html = render(view)

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
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      for token <- ctx.tokens do
        assert has_element?(view, "[aria-label='Delete #{token.title} token']")
      end
    end

    test "renders token update button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      for token <- ctx.tokens do
        assert has_element?(view, "[aria-label='Update #{token.title} token']")
      end
    end
  end

  describe "delete token modal" do
    test "renders by clicking delete token button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      refute has_element?(view, "[aria-modal='true'][role='dialog']")

      for token <- ctx.tokens do
        view
        |> element("[aria-label='Delete #{token.title} token']")
        |> render_click()

        assert has_element?(view, "[aria-modal='true'][role='dialog']")
      end
    end

    test "deletes token by clicking delete button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      for token <- ctx.tokens do
        assert has_element?(view, "td", token.title)

        view
        |> element("[aria-label='Delete #{token.title} token']")
        |> render_click()

        view
        |> element("button", "Delete")
        |> render_click()

        refute has_element?(view, "td", token.title)
      end
    end
  end

  describe "create token modal" do
    test "rendered by clicking create token button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      refute has_element?(view, "[aria-modal='true'][role='dialog']")

      view
      |> element("[aria-label='Create token']")
      |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
    end

    test "creates token ", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      title = to_string(ctx.test)

      view
      |> element("[aria-label='Create token']")
      |> render_click()

      view
      |> element("form[aria-label='Token form']")
      |> render_submit(%{"token" => %{"access" => "read", "title" => title}})

      assert render_async(view) =~ title
    end
  end

  describe "update token modal" do
    test "renders by clicking update token button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      refute has_element?(view, "[aria-modal='true'][role='dialog']")

      element(view, "[aria-label='Update #{ctx.token.title} token']")
      |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
    end

    test "updates token by clicking update button", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/tokens")

      title = Atom.to_string(ctx.test)

      for token <- ctx.tokens do
        assert has_element?(view, "td", token.title)

        view
        |> element("[aria-label='Update #{token.title} token']")
        |> render_click()

        view
        |> element("form[aria-label='Token form']")
        |> render_submit(%{"token" => %{"access" => "read", "title" => title}})

        refute has_element?(view, "td", token.title)

        assert has_element?(view, "td", title)
      end
    end
  end
end
