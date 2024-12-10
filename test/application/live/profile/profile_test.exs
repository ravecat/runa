defmodule RunaWeb.Live.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

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
end
