defmodule Runa.FilesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :files

  alias Runa.Files
  alias Runa.Files.File

  import Runa.Factory

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)

    %{uploaded_file: file, team: team}
  end

  describe "files" do
    test "returns all files", ctx do
      assert [file] = Files.get_files()
      assert file.id == ctx.uploaded_file.id
    end

    test "returns the file with given id", ctx do
      assert file = Files.get_file!(ctx.uploaded_file.id)
      assert file.id == ctx.uploaded_file.id
    end

    test "creates a file with valid data", ctx do
      project = insert(:project, team: ctx.team)

      valid_attrs = %{
        filename: Atom.to_string(ctx.test),
        project_id: project.id
      }

      assert {:ok, %File{} = file} = Files.create_file(valid_attrs)
      assert file.filename == Atom.to_string(ctx.test)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{filename: nil}
      assert {:error, %Ecto.Changeset{}} = Files.create_file(invalid_attrs)
    end

    test "updates the file with valid data ", ctx do
      update_attrs = %{filename: Atom.to_string(ctx.test)}

      assert {:ok, %File{} = file} =
               Files.update_file(ctx.uploaded_file, update_attrs)

      assert file.filename == Atom.to_string(ctx.test)
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{filename: nil}

      assert {:error, %Ecto.Changeset{}} =
               Files.update_file(ctx.uploaded_file, invalid_attrs)
    end

    test "deletes the file", ctx do
      assert {:ok, %File{}} = Files.delete_file(ctx.uploaded_file)

      assert_raise Ecto.NoResultsError, fn ->
        Files.get_file!(ctx.uploaded_file.id)
      end
    end

    test "returns a file changeset", ctx do
      assert %Ecto.Changeset{} = Files.change_file(ctx.uploaded_file)
    end
  end
end
