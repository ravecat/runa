defmodule RunaWeb.Live.Profile.ShowTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  @moduletag :profile

  import RunaWeb.Formatters
  alias Runa.Accounts

  setup ctx do
    tokens = insert_list(3, :token, user: ctx.user)

    {:ok, tokens: tokens}
  end

  describe "profile page" do
    test "renders current user name", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      assert has_element?(
               view,
               "input[aria-label='Profile name'][value='#{ctx.user.name}']"
             )
    end

    test "reflects user name update", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      assert has_element?(
               view,
               "input[aria-label='Profile name'][value='#{ctx.user.name}']"
             )

      refute has_element?(
               view,
               "input[aria-label='Profile name'][value='John Doe']"
             )

      view
      |> element("input[aria-label='Profile name']")
      |> render_blur(%{"value" => "John Doe"})

      assert {:ok, user} = Accounts.get(ctx.user.id)
      assert user.name == "John Doe"

      assert has_element?(
               view,
               "input[aria-label='Profile name'][value='John Doe']"
             )
    end

    test "name update in profile propagates to sidebar", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      sidebar = view |> element("[aria-label='Main navigation']") |> render()
      refute sidebar =~ "John Doe"

      view
      |> element("input[aria-label='Profile name']")
      |> render_blur(%{"value" => "John Doe"})

      assert view |> element("[aria-label='Main navigation']") |> render() =~
               "John Doe"
    end

    test "renders user email", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      assert has_element?(
               view,
               "input[aria-label='Profile email'][value='#{ctx.user.email}']"
             )
    end

    test "renders user creation date", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      formatted_date = format_datetime_to_view(ctx.user.inserted_at)

      assert element(view, "[aria-label='Account creation date']")
             |> render() =~ formatted_date
    end

    test "renders user last update date", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      formatted_date = format_datetime_to_view(ctx.user.updated_at)

      assert element(view, "[aria-label='Last profile update date']")
             |> render() =~ formatted_date
    end

    test "renders user avatar", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      assert has_element?(
               view,
               "[aria-label='Profile avatar'][src='#{ctx.user.avatar}']"
             )
    end

    test "reflects user avatar update", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      initial_src =
        view
        |> element("[aria-label='Profile avatar']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      view
      |> element("button[aria-label='Update avatar']")
      |> render_click()

      updated_src =
        view
        |> element("[aria-label='Profile avatar']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      refute initial_src == updated_src
      assert updated_src =~ "thumbs"
    end

    test "avatar update in profile propagates to sidebar", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      sidebar_avatar_url =
        view
        |> element("[aria-label='Main navigation']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      view
      |> element("button[aria-label='Update avatar']")
      |> render_click()

      updated_sidebar_avatar_url =
        view
        |> element("[aria-label='Main navigation']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      refute sidebar_avatar_url == updated_sidebar_avatar_url
    end

    test "reflects user avatar deletion", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      initial_src =
        view
        |> element("[aria-label='Profile avatar']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      view
      |> element("button[aria-label='Delete avatar']")
      |> render_click()

      updated_src =
        view
        |> element("[aria-label='Profile avatar']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      refute initial_src == updated_src
      assert updated_src =~ "initials"
    end

    test "delete avatar in profile propagates to sidebar", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/profile")

      sidebar_avatar_url =
        view
        |> element("[aria-label='Main navigation']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      assert sidebar_avatar_url =~ "thumbs"

      view
      |> element("button[aria-label='Delete avatar']")
      |> render_click()

      updated_sidebar_avatar_url =
        view
        |> element("[aria-label='Main navigation']")
        |> render()
        |> Floki.attribute("img", "src")
        |> List.first()

      refute sidebar_avatar_url == updated_sidebar_avatar_url
      assert updated_sidebar_avatar_url =~ "initials"
    end
  end
end
