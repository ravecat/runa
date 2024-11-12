defmodule RunaWeb.PageLive.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @moduletag :profile

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  describe "authenticated user" do
    test "can see projects page", ctx do
      {:ok, _show_live, html} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/profile")

      assert html =~ ctx.user.name
    end
  end
end
