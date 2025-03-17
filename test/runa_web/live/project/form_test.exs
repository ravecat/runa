defmodule RunaWeb.Live.Project.FormTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  alias Runa.Projects.Project
  alias RunaWeb.Live.Project.Form

  setup ctx do
    team = insert(:team)
    contributor = insert(:contributor, team: team, user: ctx.user)
    language = insert(:language, wals_code: "eng", title: "English")

    project =
      insert(:project,
        team: team,
        base_language: language,
        languages: [language]
      )

    scope = Scope.new(ctx.user)

    {:ok,
     project: project,
     team: team,
     contributor: contributor,
     language: language,
     scope: scope}
  end

  describe "project form" do
    test "renders fields", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      assert has_element?(view, "[aria-label='Project name']")
      assert has_element?(view, "[aria-label='Project description']")
      assert has_element?(view, "label:fl-contains('Languages') ~ select")
      assert has_element?(view, "label:fl-contains('Base language') ~ select")
    end

    test "requires name", ctx do
      language = insert(:language, wals_code: "rus", title: "Russian")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      element(view, "[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "",
          "bases_language_id" => language.id,
          "languages" => []
        }
      })

      assert has_element?(view, "p", "can't be blank")
    end

    @tag :skip
    test "requires base language", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      element(view, "[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "bases_language_id" => "",
          "languages" => []
        }
      })

      assert has_element?(view, "p", "can't be blank")
    end

    test "creates project", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: %Project{team_id: ctx.team.id}
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => ctx.language.id,
          "languages" => [ctx.language.id]
        }
      })

      assert %Project{} = Repo.get_by(Project, name: "New Project")
    end

    test "updates project", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => "New Name"}})

      assert %Project{} = Repo.get_by(Project, name: "New Name")
    end
  end

  describe "project form (base language field)" do
    test "displays selected base language", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"base_language_id" => ctx.language.id}})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('English')[selected]"
             )

      assert element(
               view,
               "[aria-label='Project form'] [aria-label='Selected option']"
             )
             |> render() =~ "English"
    end
  end

  describe "project form (languages field)" do
    @tag :skip
    test "displays selected language values", ctx do
      language = insert(:language, wals_code: "rus", title: "Russian")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => [language.id]}})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('#{language.id}')[selected]"
             )

      assert element(
               view,
               "[aria-label='Project form'] [aria-label='Selected options']"
             )
             |> render() =~ "Russian"
    end

    test "clear all selected languages", ctx do
      language = insert(:language, wals_code: "rus", title: "Russian")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => [language.id]}})

      view
      |> element(
        "[aria-label='Project form'] label:fl-contains('Languages') + [role='combobox'] [aria-label='Clear selection']"
      )
      |> render_click()

      refute element(
               view,
               "label:fl-contains('Languages') + [role='combobox'] [aria-label='Selected options']"
             )
             |> render() =~
               "Russian"
    end

    @tag :skip
    test "clear selected languages", ctx do
      language = insert(:language, wals_code: "rus", title: "Russian")

      insert(:locale, project: ctx.project, language: language)

      {:ok, view, _} =
        live_isolated_component(Form, %{
          scope: ctx.scope,
          data: ctx.project,
          team_id: ctx.team.id
        })

      assert element(view, "[aria-label='Selected options']")
             |> render() =~
               "Russian"

      view
      |> element(
        "[aria-label='Project form'] [aria-label='Clear #{language.id} selection']"
      )
      |> render_click()

      refute element(view, "[aria-label='Selected options']")
             |> render() =~
               "Russian"
    end
  end
end
