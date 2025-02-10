defmodule RunaWeb.Live.Project.ShowTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  setup do
    team = insert(:team)
    user = insert(:user)
    contributor = insert(:contributor, team: team, user: user)
    project = insert(:project, team: team)
    language = insert(:language, wals_code: "eng", title: "English")

    {:ok,
     user: user,
     project: project,
     team: team,
     contributor: contributor,
     language: language}
  end

  describe "project dashboard" do
    test "redirects to default section", ctx do
      expected_redirect = "/projects/#{ctx.project.id}?section=settings"

      assert {:error, {:live_redirect, %{to: ^expected_redirect}}} =
               ctx.conn
               |> put_session(:user_id, ctx.user.id)
               |> live(~p"/projects/#{ctx.project.id}")

      assert {:error, {:live_redirect, %{to: ^expected_redirect}}} =
               ctx.conn
               |> put_session(:user_id, ctx.user.id)
               |> live(~p"/projects/#{ctx.project.id}?section=unknown")
    end
  end
end
