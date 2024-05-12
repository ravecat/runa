defmodule Runa.ProjectsTest do
  @moduledoc false

  use Runa.DataCase

  alias Runa.Projects
  alias Runa.Projects.Project

  import Runa.ProjectsFixtures

  @invalid_attrs %{name: nil, description: nil}

  describe "projects" do
    setup [:create_aux_project]

    test "get_projects/0 returns all projects", ctx do
      assert Projects.get_projects() == [ctx.project]
    end

    test "get_project!/1 returns the project with given id", ctx do
      assert Projects.get_project!(ctx.project.id) == ctx.project
    end

    test "create_project/1 with valid data creates a project" do
      valid_attrs = %{name: "some name", description: "some description"}

      assert {:ok, %Project{} = project} = Projects.create_project(valid_attrs)
      assert project.name == "some name"
      assert project.description == "some description"
    end

    test "create_project/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Projects.create_project(@invalid_attrs)
    end

    test "update_project/2 with valid data updates the project", ctx do
      update_attrs = %{
        name: "some updated name",
        description: "some updated description"
      }

      assert {:ok, %Project{} = project} =
               Projects.update_project(ctx.project, update_attrs)

      assert project.name == "some updated name"
      assert project.description == "some updated description"
    end

    test "update_project/2 with invalid data returns error changeset", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Projects.update_project(ctx.project, @invalid_attrs)

      assert ctx.project == Projects.get_project!(ctx.project.id)
    end

    test "delete_project/1 deletes the project", ctx do
      assert {:ok, %Project{}} = Projects.delete_project(ctx.project)

      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project!(ctx.project.id)
      end
    end

    test "change_project/1 returns a project changeset", ctx do
      assert %Ecto.Changeset{} = Projects.change_project(ctx.project)
    end
  end
end
