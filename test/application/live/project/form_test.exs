defmodule RunaWeb.Live.Project.FormTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  alias Runa.Projects.Project
  alias RunaWeb.Live.Project.Form

  setup do
    team = insert(:team)
    user = insert(:user)
    contributor = insert(:contributor, team: team, user: user)
    project = insert(:project, team: team)

    {:ok, user: user, project: project, team: team, contributor: contributor}
  end

  describe "project form" do
    test "renders fields", ctx do
      {:ok, view, _} = live_isolated_component(Form, %{data: ctx.project})

      assert has_element?(view, "[aria-label='Project name']")
      assert has_element?(view, "[aria-label='Project description']")
    end

    test "requires name", ctx do
      {:ok, view, _} = live_isolated_component(Form, %{data: ctx.project})

      element(view, "[aria-label='Project form']")
      |> render_change(%{"project" => %{"name" => ""}})

      assert has_element?(view, "p", "can't be blank")
    end

    test "creates project", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Project"}})

      assert %Project{} = Repo.get_by(Project, name: "New Project")
    end

    test "broadcasts message on successful create", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      PubSub.subscribe("projects:#{ctx.team.id}")

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Name"}})

      assert_receive {:created_project, %{name: "New Name"}}
    end

    test "updates project", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Name"}})

      assert %Project{} = Repo.get_by(Project, name: "New Name")
    end

    test "broadcasts message on successful update", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      PubSub.subscribe("projects:#{ctx.team.id}")

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Name"}})

      assert_receive {:updated_project, %{name: "New Name"}}
    end
  end
end