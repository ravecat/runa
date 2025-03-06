defmodule RunaWeb.Live.Project.ShowTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  setup ctx do
    team = insert(:team)
    contributor = insert(:contributor, team: team, user: ctx.user)
    project = insert(:project, team: team)
    language = insert(:language, wals_code: "eng", title: "English")

    {:ok,
     project: project, team: team, contributor: contributor, language: language}
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
