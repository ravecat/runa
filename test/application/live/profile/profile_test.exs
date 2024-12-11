defmodule RunaWeb.Live.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  @moduletag :profile

  import RunaWeb.Formatters
  alias Runa.Accounts

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

  test "authenticated user can see name", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    assert has_element?(
             view,
             "input[aria-label='Profile name'][value='#{ctx.user.name}']"
           )
  end

  test "authenticated user can update name", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

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
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    sidebar = view |> element("[aria-label='Main navigation']") |> render()
    refute sidebar =~ "John Doe"

    view
    |> element("input[aria-label='Profile name']")
    |> render_blur(%{"value" => "John Doe"})

    assert view |> element("[aria-label='Main navigation']") |> render() =~ "John Doe"
  end

  test "authenticated user can see email", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    assert has_element?(
             view,
             "input[aria-label='Profile email'][value='#{ctx.user.email}']"
           )
  end

  test "authenticated user can see creation date", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    formatted_date = format_datetime_to_view(ctx.user.inserted_at)

    assert has_element?(
             view,
             "input[aria-label='Account creation date'][value='#{formatted_date}']"
           )
  end

  test "authenticated user can see last update date", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    formatted_date = format_datetime_to_view(ctx.user.updated_at)

    assert has_element?(
             view,
             "input[aria-label='Last profile update date'][value='#{formatted_date}']"
           )
  end

  test "authenticated user can see avatar", ctx do
    {:ok, view, _} =
      ctx.conn
      |> put_session(:user_id, ctx.user.id)
      |> live(~p"/profile")

    assert has_element?(view, "img[src='#{ctx.user.avatar}']")
  end
end
