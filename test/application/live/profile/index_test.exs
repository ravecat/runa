defmodule RunaWeb.PageLive.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase

  @moduletag :profile

  import Phoenix.LiveViewTest

  import Runa.AccountsFixtures

  describe "authenticated user" do
    setup do
      user = create_aux_user()

      %{user: user}
    end

    test "can see projects page", ctx do
      {:ok, _show_live, html} =
        ctx.conn
        |> put_session(:current_user, ctx.user)
        |> live(~p"/profile")

      assert html =~ ctx.user.name
    end
  end

  describe "unauthenticated user" do
    test "can't see projects page", ctx do
      assert {:error, {:redirect, %{to: "/"}}} = live(ctx.conn, ~p"/profile")
    end
  end
end
