defmodule Runa.ProjectsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :projects

  alias Runa.{Projects, Projects.Project}

  import Runa.{ProjectsFixtures, TeamsFixtures}

  setup do
    project = create_aux_project()

    %{project: project}
  end

  describe "projects context" do
    test "returns all projects", ctx do
      assert Projects.get_projects() == [ctx.project]
    end

    test "returns the project with given id", ctx do
      assert Projects.get_project!(ctx.project.id) == ctx.project
    end

    test "creates a project with valid data" do
      team = create_aux_team()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        team_id: team.id
      }

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == valid_attrs.name
      assert project.description == valid_attrs.description
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Projects.create_project(invalid_attrs)
    end

    test "updates the project with valid data", ctx do
      update_attrs = %{
        name: "some updated name",
        description: "some updated description"
      }

      assert {:ok, %Project{} = project} =
               Projects.update_project(ctx.project, update_attrs)

      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Projects.update_project(ctx.project, invalid_attrs)

      assert ctx.project == Projects.get_project!(ctx.project.id)
    end

    test "deletes the project", ctx do
      assert {:ok, %Project{}} = Projects.delete_project(ctx.project)

      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project!(ctx.project.id)
      end
    end

    test "returns a project changeset", ctx do
      assert %Ecto.Changeset{} = Projects.change_project(ctx.project)
    end
  end
end
