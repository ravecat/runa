defmodule RunaWeb.Live.Project.ShowTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  setup ctx do
    user = insert(:user)
    conn = Plug.Conn.put_session(ctx.conn, :user_id, user.id)
    team = insert(:team)
    contributor = insert(:contributor, team: team, user: user)

    project =
      insert(:project, base_language: fn -> build(:language) end, team: team)

    language = insert(:language, wals_code: "eng", title: "English")

    {:ok,
     user: user,
     conn: conn,
     project: project,
     team: team,
     contributor: contributor,
     language: language}
  end

  describe "project dashboard" do
    test "redirects to default section", ctx do
      expected_redirect = "/projects/#{ctx.project.id}?section=files"

      assert {:error, {:live_redirect, %{to: ^expected_redirect}}} =
               live(ctx.conn, ~p"/projects/#{ctx.project.id}")

      assert {:error, {:live_redirect, %{to: ^expected_redirect}}} =
               live(ctx.conn, ~p"/projects/#{ctx.project.id}?section=unknown")
    end
  end
end
