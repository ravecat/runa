defmodule Runa.ProjectsTest do
  use Runa.DataCase, async: true

  @moduletag :projects

  alias Runa.Projects
  alias Runa.Projects.Project

  setup do
    user = insert(:user)
    team = insert(:team)

    project =
      insert(:project, base_language: fn -> build(:language) end, team: team)

    {:ok, project: project, team: team, scope: Scope.new(user)}
  end

  describe "projects context" do
    test "returns all entities", ctx do
      {:ok, {[project], %{}}} = Projects.index(ctx.scope)

      assert project.id == ctx.project.id
    end

    test "returns entity with given id", ctx do
      assert {:ok, project} = Projects.get(ctx.scope, ctx.project.id)
      assert project.id == ctx.project.id
    end

    test "creates enitity with valid data", ctx do
      team = insert(:team)
      language = insert(:language)

      attrs = %{
        name: "some name",
        description: "some description",
        team_id: team.id,
        base_language_id: language.id
      }

      assert {:ok, %Project{}} = Projects.create(ctx.scope, attrs)
    end

    test "send message on successful create", ctx do
      team = insert(:team)
      language = insert(:language)

      Projects.subscribe(ctx.scope)

      attrs = %{
        name: "some name",
        description: "some description",
        team_id: team.id,
        base_language_id: language.id
      }

      {:ok, data} = Projects.create(ctx.scope, attrs)

      assert_receive %Events.ProjectCreated{data: ^data}
    end

    test "returns error changeset during creation with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Projects.create(ctx.scope, invalid_attrs)
    end

    test "updates entity with valid data", ctx do
      language = insert(:language)

      attrs = %{
        name: "some updated name",
        description: "some updated description",
        base_language_id: language.id
      }

      assert {:ok, %Project{} = project} =
               Projects.update(ctx.scope, ctx.project, attrs)

      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "sends message on successful update", ctx do
      language = insert(:language)

      Projects.subscribe(ctx.scope)

      attrs = %{
        name: "some updated name",
        description: "some updated description",
        base_language_id: language.id
      }

      {:ok, data} = Projects.update(ctx.scope, ctx.project, attrs)

      assert_receive %Events.ProjectUpdated{data: ^data}
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Projects.update(ctx.scope, ctx.project, invalid_attrs)
    end

    test "deletes entity", ctx do
      assert {:ok, %Project{}} = Projects.delete(ctx.scope, ctx.project)

      assert {:error, %Ecto.NoResultsError{}} =
               Projects.get(ctx.scope, ctx.project.id)
    end

    test "returns changeset", ctx do
      assert %Ecto.Changeset{} = Projects.change(ctx.project)
    end
  end
end
