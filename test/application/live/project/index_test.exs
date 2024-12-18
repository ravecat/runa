defmodule RunaWeb.Live.Project.IndexTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :projects

  setup do
    team = insert(:team)
    user = insert(:user)
    contributor = insert(:contributor, team: team, user: user)
    projects = insert_list(2, :project, team: team)

    {:ok, user: user, projects: projects, team: team, contributor: contributor}
  end

  describe "projects view" do
    test "renders projects cards", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert Enum.all?(
               ctx.projects,
               &has_element?(view, "[aria-label='Project #{&1.name} card']")
             )
    end

    test "renders edit button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert Enum.all?(
               ctx.projects,
               &has_element?(view, "[aria-label='Edit #{&1.name} project']")
             )
    end

    test "renders delete button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      for project <- ctx.projects do
        assert has_element?(
                 view,
                 "[aria-label='Delete #{project.name} project']"
               )
      end
    end

    test "renders duplicate button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      for project <- ctx.projects do
        assert has_element?(
                 view,
                 "[aria-label='Duplicate #{project.name} project']"
               )
      end
    end

    test "renders projects titles", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert Enum.all?(ctx.projects, fn project ->
               view
               |> element("[aria-label='Project #{project.name} card']")
               |> render() =~ project.name
             end)
    end

    test "renders projects statistics", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      for project <- ctx.projects do
        assert has_element?(
                 view,
                 "[aria-label='Project #{project.name} statistics']"
               )
      end
    end

    test "renders projects languages block", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      for project <- ctx.projects do
        assert has_element?(
                 view,
                 "[aria-label='Project #{project.name} languages']"
               )
      end
    end

    test "renders files count", ctx do
      project = insert(:project, team: ctx.team)
      files = insert_list(2, :file, project: project)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Files']")
             |> render() =~ "#{length(files)}"
    end

    test "renders languages count", ctx do
      languages = insert_list(2, :language)
      project = insert(:project, team: ctx.team, languages: languages)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Languages']")
             |> render() =~ "2"
    end

    test "renders done percentage", ctx do
      project = insert(:project, team: ctx.team)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Done']")
             |> render() =~ "0%"
    end

    test "renders keys count", ctx do
      project = insert(:project, team: ctx.team)
      keys = insert_list(2, :key, project: project)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Keys']")
             |> render() =~ "#{Enum.count(keys)}"
    end
  end

  describe "projects compact view" do
    test "renders project languages list", ctx do
      language = insert(:language)
      project = insert(:project, team: ctx.team, languages: [language])

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} languages']")
             |> render() =~ language.wals_code
    end
  end

  describe "toolbar block" do
    test "renders create project button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Create new project']")
    end

    test "renders list view button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Compact view']")
    end

    test "renders row view button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Expand view']")
    end

    test "renders grid view button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Grid view']")
    end
  end

  describe "edit project modal" do
    test "rendered by click edit button", ctx do
      project = insert(:project, team: ctx.team)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      element(view, "button[aria-label='Edit #{project.name} project']")
      |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
      assert has_element?(view, "[aria-label='Project form']")
    end

    test "edits project by clicking save button", ctx do
      project = insert(:project, team: ctx.team)

      title = Atom.to_string(ctx.test)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      refute has_element?(view, "[aria-label='Project #{title} card']")

      element(view, "button[aria-label='Edit #{project.name} project']")
      |> render_click()

      element(view, "[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => title}})

      assert view
             |> element("[aria-label='Project #{title} card']")
             |> render() =~ title
    end
  end

  describe "delete project button" do
    test "rendered by click delete button", ctx do
      project = List.first(ctx.projects)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      element(view, "button[aria-label='Delete #{project.name} project']")
      |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
    end

    test "deletes project by clicking delete button", ctx do
      project = List.first(ctx.projects)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      element(view, "button[aria-label='Delete #{project.name} project']")
      |> render_click()

      element(
        view,
        "button[aria-label='Confirm delete #{project.name} project']"
      )
      |> render_click()

      refute has_element?(view, "[aria-label='Project #{project.name} card']")
    end
  end

  describe "create project modal" do
    test "rendered by click create button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      element(view, "button[aria-label='Create new project']")
      |> render_click()

      assert has_element?(view, "[aria-modal='true'][role='dialog']")
      assert has_element?(view, "[aria-label='Project form']")
    end

    test "creates project by clicking create button", ctx do
      title = Atom.to_string(ctx.test)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      refute has_element?(view, "[aria-label='Project #{title} card']")

      element(view, "button[aria-label='Create new project']")
      |> render_click()

      element(view, "[aria-label='Project form']")
      |> render_submit(%{"project" => %{"name" => title}})

      assert view
             |> element("[aria-label='Project #{title} card']")
             |> render() =~ title
    end
  end

  describe "duplicated project" do
    test "created by clicking duplicate button", ctx do
      project = List.first(ctx.projects)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      element(view, "button[aria-label='Duplicate #{project.name} project']")
      |> render_click()

      assert element(
               view,
               "[aria-label='Project #{project.name} (copy) card']"
             )
             |> render() =~ "#{project.name} (copy)"
    end
  end
end
