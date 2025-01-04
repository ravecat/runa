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
      {:ok, view, _} =
        live_isolated_component(Form, %{data: ctx.project, team: ctx.team})

      assert has_element?(view, "[aria-label='Project name']")
      assert has_element?(view, "[aria-label='Project description']")
      assert has_element?(view, "[aria-label='Project languages']")
    end

    test "requires name", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{data: ctx.project, team: ctx.team})

      element(view, "[aria-label='Project form']")
      |> render_change(%{"project" => %{"name" => "", "languages" => []}})

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
          data: Repo.preload(ctx.project, :languages),
          team: ctx.team
        })

      PubSub.subscribe("projects:#{ctx.team.id}")

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Name"}})

      assert_receive {:updated_project, %{name: "New Name", languages: []}}
    end

    test "displays selected language values", ctx do
      insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => ["eng"]}})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('English')[selected]"
             )

      assert element(
               view,
               "[aria-label='Project form'] [aria-label='Selected options']"
             )
             |> render() =~ "eng"
    end

    test "clear all selected languages", ctx do
      insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => ["eng"]}})

      view
      |> element("[aria-label='Project form'] [aria-label='Clear selection']")
      |> render_click()

      assert has_element?(
               view,
               "label:fl-contains('Languages') [aria-label='Selected options']",
               ""
             )
    end

    test "clear selected language", ctx do
      insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => ["eng"]}})

      view
      |> element(
        "[aria-label='Project form'] [aria-label='Clear eng selection']"
      )
      |> render_click()

      assert has_element?(
               view,
               "label:fl-contains('Languages') [aria-label='Selected options']",
               ""
             )
    end

    test "searches languages", ctx do
      insert(:language, wals_code: "eng", title: "English")
      insert(:language, wals_code: "fra", title: "French")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      element(
        view,
        "[aria-label='Project form'] [aria-label='Search languages']"
      )
      |> render_change(%{"query" => "English"})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('English')"
             )

      refute has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('French')"
             )
    end
  end
end
