defmodule Runa.FilesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :files

  alias Runa.{Files, Files.File}

  import Runa.{FilesFixtures, ProjectsFixtures}

  setup do
    file = create_aux_file()

    %{uploaded_file: file}
  end

  describe "files" do
    test "returns all files", ctx do
      assert Files.get_files() == [ctx.uploaded_file]
    end

    test "returns the file with given id", ctx do
      assert Files.get_file!(ctx.uploaded_file.id) == ctx.uploaded_file
    end

    test "creates a file with valid data" do
      project = create_aux_project()
      valid_attrs = %{filename: "some filename", project_id: project.id}

      assert {:ok, %File{} = file} = Files.create_file(valid_attrs)
      assert file.filename == "some filename"
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{filename: nil}
      assert {:error, %Ecto.Changeset{}} = Files.create_file(invalid_attrs)
    end

    test "updates the file with valid data ", ctx do
      update_attrs = %{filename: "some updated filename"}

      assert {:ok, %File{} = file} =
               Files.update_file(ctx.uploaded_file, update_attrs)

      assert file.filename == "some updated filename"
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{filename: nil}

      assert {:error, %Ecto.Changeset{}} =
               Files.update_file(ctx.uploaded_file, invalid_attrs)

      assert ctx.uploaded_file == Files.get_file!(ctx.uploaded_file.id)
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
