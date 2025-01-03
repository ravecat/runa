defmodule Runa.ProjectsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :projects

  alias Runa.Projects
  alias Runa.Projects.Project

  setup do
    team = insert(:team)
    project = insert(:project, team: team)

    {:ok, project: project, team: team}
  end

  describe "projects context" do
    test "returns all entities", ctx do
      {:ok, {[project], %{}}} = Projects.index()

      assert project.id == ctx.project.id
    end

    test "returns entity with given id", ctx do
      assert {:ok, project} = Projects.get(ctx.project.id)
      assert project.id == ctx.project.id
    end

    test "creates enitity with valid data" do
      team = insert(:team)

      attrs = %{
        name: "some name",
        description: "some description",
        team_id: team.id
      }

      assert {:ok, %Project{name: name, description: description}} =
               Projects.create(attrs)

      assert attrs == %{
               name: name,
               description: description,
               team_id: team.id
             }
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} = Projects.create(invalid_attrs)
    end

    test "updates entity with valid data", ctx do
      update_attrs = %{
        name: "some updated name",
        description: "some updated description"
      }

      assert {:ok, %Project{} = project} =
               Projects.update(ctx.project, update_attrs)

      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Projects.update(ctx.project, invalid_attrs)
    end

    test "deletes entity", ctx do
      assert {:ok, %Project{}} = Projects.delete(ctx.project)

      assert {:error, %Ecto.NoResultsError{}} = Projects.get(ctx.project.id)
    end

    test "returns changeset", ctx do
      assert %Ecto.Changeset{} = Projects.change(ctx.project)
    end
  end
end
