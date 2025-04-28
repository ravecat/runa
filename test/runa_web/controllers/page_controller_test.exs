defmodule RunaWeb.PageControllerTest do
  use RunaWeb.ConnCase, async: true

  setup do
    %{user: insert(:user)}
  end

  test "GET / redirects to /profile if user is authenticated", ctx do
    conn = put_session(ctx.conn, :user_id, ctx.user.id) |> get(~p"/")

    assert redirected_to(conn, 302) =~ ~p"/profile"
  end
end
