defmodule RunaWeb.Live.Project.IndexTest do
  use RunaWeb.FeatureCase, auth: true

  @moduletag :projects

  setup ctx do
    team = insert(:team)
    contributor = insert(:contributor, team: team, user: ctx.user)
    language = insert(:language, wals_code: "eng", title: "English")
    projects = insert_list(2, :project, team: team, base_language: language)

    {:ok,
     projects: projects,
     team: team,
     contributor: contributor,
     language: language}
  end

  describe "projects view" do
    feature "renders projects cards", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        assert_has(
          ctx.session,
          Query.css("[aria-label=\"Project #{project.name} card\"]")
        )
      end
    end

    feature "renders edit button", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        assert_has(
          session,
          Query.css("[aria-label=\"Edit #{project.name} project\"]")
        )
      end
    end

    feature "renders delete button", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        assert_has(
          session,
          Query.css("[aria-label=\"Delete #{project.name} project\"]")
        )
      end
    end

    feature "renders duplicate button", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        assert_has(
          session,
          Query.css("[aria-label=\"Duplicate #{project.name} project\"]")
        )
      end
    end

    feature "renders project locales", ctx do
      language = insert(:language)

      for project <- ctx.projects do
        insert(:locale, project: project, language: language)

        ctx.session
        |> visit("/projects")
        |> assert_text(
          Query.css("[aria-label=\"Project #{project.name} languages\"]"),
          language.title || language.wals_code || language.iso_code ||
            language.glotto_code
        )
        |> assert_has(
          Query.css(
            "[aria-label=\"Project #{project.name} languages\"] [role='listitem']",
            count: 1
          )
        )
      end
    end

    feature "renders projects statistics", ctx do
      for project <- ctx.projects do
        insert_list(2, :file, project: project)

        insert_list(2, :locale,
          project: project,
          language: fn -> build(:language) end
        )

        ctx.session
        |> visit("/projects")
        |> find(
          Query.css("[aria-label=\"Project #{project.name} statistics\"]")
        )
        |> assert_has(
          Query.css("[aria-label=\"Project #{project.name} files count\"]",
            text: "2"
          )
        )
        |> assert_has(
          Query.css("[aria-label=\"Project #{project.name} languages count\"]",
            text: "2"
          )
        )
        |> assert_has(
          Query.css(
            "[aria-label=\"Project #{project.name} translation progress\"]"
          )
        )
        |> assert_has(
          Query.css("[aria-label=\"Project #{project.name} keys count\"]")
        )
      end
    end
  end

  describe "projects toolbar" do
    feature "renders create project button", ctx do
      visit(ctx.session, "/projects")
      |> assert_has(
        Query.css("[aria-label=\"Create new project\"]", text: "New")
      )
    end
  end

  describe "edit project modal" do
    feature "rendered by click edit button", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        session
        |> click(Query.css("[aria-label=\"Edit #{project.name} project\"]"))
        |> assert_has(Query.css("[aria-modal='true'][role='dialog']"))
        |> assert_has(Query.css("[aria-label=\"Project form\"]"))
      end
    end

    feature "edits project by clicking update button", ctx do
      session = visit(ctx.session, "/projects")

      for project <- ctx.projects do
        session
        |> click(Query.css("[aria-label=\"Edit #{project.name} project\"]"))
        |> fill_in(Query.css("[aria-label=\"Project name\"]"), with: "New name")
        |> click(Query.css("[aria-label=\"Confirm update project\"]"))
        |> assert_has(Query.css("[aria-label=\"Project form\"]", count: 0))
      end
    end
  end

  # describe "delete project action" do
  #   test "renders delete project dialog", ctx do
  #     project = List.first(ctx.projects)

  #     {:ok, view, _} = live(ctx.conn, ~p"/projects")

  #     element(view, "[aria-label='Delete #{project.name} project']")
  #     |> render_click()

  #     assert has_element?(view, "[aria-modal='true'][role='dialog']")
  #   end

  #   test "deletes project by clicking delete button", ctx do
  #     project = List.first(ctx.projects)

  #     {:ok, view, _} = live(ctx.conn, ~p"/projects")

  #     element(view, "[aria-label='Delete #{project.name} project']")
  #     |> render_click()

  #     element(view, "[aria-label='Confirm delete project']")
  #     |> render_click()

  #     refute has_element?(view, "[aria-label='Project #{project.name} card']")
  #   end
  # end

  # describe "create project modal" do
  #   test "rendered by click create button", ctx do
  #     {:ok, view, _} = live(ctx.conn, ~p"/projects")

  #     refute has_element?(view, "[aria-modal='true'][role='dialog']")

  #     element(view, "[aria-label='Create new project']")
  #     |> render_click()

  #     assert has_element?(view, "[aria-modal='true'][role='dialog']")
  #     assert has_element?(view, "[aria-label='Project form']")
  #   end

  #   test "creates project by clicking create button", ctx do
  #     title = Atom.to_string(ctx.test)

  #     {:ok, view, _} = live(ctx.conn, ~p"/projects")

  #     refute has_element?(view, "[aria-label='Project #{title} card']")

  #     element(view, "[aria-label='Create new project']")
  #     |> render_click()

  #     element(view, "[aria-label='Project form']")
  #     |> render_submit(%{
  #       "project" => %{"name" => title, "base_language_id" => ctx.language.id}
  #     })

  #     assert view
  #            |> element("[aria-label='Project #{title} card']")
  #            |> render() =~ title

  #     refute has_element?(view, "[aria-modal='true'][role='dialog']")

  #     assert_patched(view, "/projects")
  #   end
  # end

  # describe "duplicated project" do
  #   test "created by clicking duplicate button", ctx do
  #     project = List.first(ctx.projects)

  #     {:ok, view, _} = live(ctx.conn, ~p"/projects")

  #     element(view, "button[aria-label='Duplicate #{project.name} project']")
  #     |> render_click()

  #     assert element(view, "[aria-label='Project #{project.name} (copy) card']")
  #            |> render() =~ "#{project.name} (copy)"
  #   end
  # end
end
