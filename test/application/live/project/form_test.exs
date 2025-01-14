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
      assert has_element?(view, "label:fl-contains('Languages') ~ select")
      assert has_element?(view, "label:fl-contains('Base language') ~ select")
    end

    test "requires name", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{data: ctx.project, team: ctx.team})

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

    test "requires base language", ctx do
      {:ok, view, _} =
        live_isolated_component(Form, %{data: ctx.project, team: ctx.team})

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
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => language.id
        }
      })

      assert %Project{} = Repo.get_by(Project, name: "New Project")
    end

    test "broadcasts message on successful create", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      PubSub.subscribe("projects:#{ctx.team.id}")

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{"name" => "New Name", "base_language_id" => language.id}
      })

      assert_receive {:created_project, %{name: "New Name"}}
    end

    test "updates project", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{"name" => "New Name", "base_language_id" => language.id}
      })

      assert %Project{} = Repo.get_by(Project, name: "New Name")
    end

    test "broadcasts message on successful update", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: Repo.preload(ctx.project, :languages),
          team: ctx.team
        })

      PubSub.subscribe("projects:#{ctx.team.id}")

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{"name" => "New Name", "base_language_id" => language.id}
      })

      assert_receive {:updated_project, %{name: "New Name", languages: []}}
    end
  end

  describe "project form (base language field)" do
    test "displays selected base language", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"base_language_id" => language.id}})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('English')[selected]"
             )

      assert element(
               view,
               "[aria-label='Project form'] [aria-label='Selected option']"
             )
             |> render() =~ "English (eng)"
    end

    test "creates project", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => language.id,
          "languages" => [language.id]
        }
      })

      data =
        Repo.get_by(Project, name: "New Project")
        |> Repo.preload(:base_language)

      assert data.base_language == language
    end

    test "updates project", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => language.id,
          "languages" => [language.id]
        }
      })

      data =
        Repo.get_by(Project, name: "New Project")
        |> Repo.preload(:base_language)

      assert data.base_language == language
    end
  end

  describe "project form (languages field)" do
    test "displays selected language values", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_change(%{"project" => %{"languages" => [language.id]}})

      assert has_element?(
               view,
               "[aria-label='Project form'] option:fl-contains('English')[selected]"
             )

      assert element(
               view,
               "[aria-label='Project form'] [aria-label='Selected options']"
             )
             |> render() =~ "English (eng)"
    end

    test "clear all selected languages", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
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
               "English (eng)"
    end

    test "clear selected languages", ctx do
      language = insert(:language, wals_code: "eng", title: "English")
      insert(:locale, project: ctx.project, language: language)

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      assert element(
               view,
               "[aria-label='Selected options']"
             )
             |> render() =~
               "English (eng)"

      view
      |> element(
        "[aria-label='Project form'] [aria-label='Clear #{language.id} selection']"
      )
      |> render_click()

      refute element(
               view,
               "[aria-label='Selected options']"
             )
             |> render() =~
               "English (eng)"
    end

    test "creates project", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: %Project{},
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => language.id,
          "languages" => [language.id]
        }
      })

      data =
        Repo.get_by(Project, name: "New Project") |> Repo.preload(:languages)

      assert data.languages == [language]
    end

    test "updates project", ctx do
      language = insert(:language, wals_code: "eng", title: "English")

      {:ok, view, _} =
        live_isolated_component(Form, %{
          data: ctx.project,
          team: ctx.team
        })

      view
      |> element("[aria-label='Project form']")
      |> render_submit(%{
        "project" => %{
          "name" => "New Project",
          "base_language_id" => language.id,
          "languages" => [language.id]
        }
      })

      data =
        Repo.get_by(Project, name: "New Project") |> Repo.preload(:languages)

      assert data.languages == [language]
    end
  end
end
