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

  describe "projects compact view" do
    test "renders projects cards", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      for project <- ctx.projects do
        assert has_element?(view, "[aria-label='Project #{project.name} card']")
      end
    end

    test "renders projects titles", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      Enum.each(ctx.projects, fn project ->
        assert view
               |> element("[aria-label='Project #{project.name} card']")
               |> render() =~ project.name
      end)
    end

    test "renders projects statistics block", ctx do
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

  describe "card statistic block" do
    test "render team count", ctx do
      contributors =
        [ctx.contributor] ++
          insert_list(2, :contributor,
            team: ctx.team,
            user: fn -> build(:user) end
          )

      project = insert(:project, team: ctx.team)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Team']")
             |> render() =~ "#{length(contributors)}"
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
             |> render() =~ "100%"
    end

    test "renders keys count", ctx do
      project = insert(:project, team: ctx.team)

      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert view
             |> element("[aria-label='Project #{project.name} Keys']")
             |> render() =~ "10"
    end
  end

  describe "toolbar buttons" do
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

      assert has_element?(view, "[aria-label='List view']")
    end

    test "renders row view button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Row view']")
    end

    test "renders grid view button", ctx do
      {:ok, view, _} =
        ctx.conn
        |> put_session(:user_id, ctx.user.id)
        |> live(~p"/projects")

      assert has_element?(view, "[aria-label='Grid view']")
    end
  end
end
