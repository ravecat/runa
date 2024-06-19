defmodule RunaWeb.PageLive.ProfileTest do
  @moduledoc false

  use RunaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Runa.Factory

  @moduletag :profile
  @roles Application.compile_env(:runa, :permissions)

  describe "authenticated user" do
    setup do
      insert(:role, title: @roles[:owner])
      teams = insert_list(2, :team)
      user = insert(:user, teams: teams)

      {:ok, user: user}
    end

    test "can see projects page", ctx do
      {:ok, _show_live, html} =
        ctx.conn
        |> put_session(:current_user, Map.take(ctx.user, [:email, :uid]))
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