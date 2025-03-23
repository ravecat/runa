defmodule RunaWeb.Live.Project.E2EIndexTest do
  use RunaWeb.FeatureCase, async: true

  @moduletag :projects

  setup ctx do
    team = insert(:team)
    contributor = insert(:contributor, team: team, user: ctx.user)
    language = insert(:language, wals_code: "eng", title: "English")
    projects = insert_list(2, :project, team: team, base_language: language)
    file = insert(:file, project: Enum.at(projects, 0))

    {:ok,
     projects: projects,
     team: team,
     contributor: contributor,
     localization_file: file,
     language: language}
  end

  feature "projects page header", %{session: session} do
    session
    |> visit("/projects")
    |> take_screenshot()
    |> find(Query.css("h3[aria-label='Projects']"))
    |> assert_text("Projects")
  end

  feature "projects page create new project button", %{session: session} do
    session
    |> visit("/projects")
    |> take_screenshot()
    |> find(Query.css("[aria-label='Create new project']"))
    |> assert_text("New")
  end
end
