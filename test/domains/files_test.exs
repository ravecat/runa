defmodule Runa.FilesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :files

  alias Runa.Files
  alias Runa.Files.File

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)

    %{uploaded_file: file, team: team}
  end

  describe "files" do
    test "returns all files", ctx do
      assert [file] = Files.index()
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

      assert {:ok, %File{} = file} = Files.create(valid_attrs)
      assert file.filename == Atom.to_string(ctx.test)
    end

    test "creates a file with keys from upload entry", ctx do
      project = insert(:project, team: ctx.team)
      language = insert(:language)
      meta = %{project_id: project.id, language_id: language.id}
      upload_entry = %{client_name: "test_file.csv"}

      data = [
        {"key1", "value1"},
        {"key2", "value2"}
      ]

      assert {:ok, data} = Files.create(upload_entry, meta, data)

      assert is_struct(data, File)

      project_id = project.id

      assert %{
               filename: "test_file.csv",
               project_id: ^project_id
             } = data

      assert [
               %{
                 name: "key1",
                 translations: [
                   %{
                     translation: "value1"
                   }
                 ]
               },
               %{
                 name: "key2",
                 translations: [
                   %{
                     translation: "value2"
                   }
                 ]
               }
             ] = data.keys
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{filename: nil}
      assert {:error, %Ecto.Changeset{}} = Files.create(invalid_attrs)
    end

    test "updates the file with valid data ", ctx do
      update_attrs = %{filename: Atom.to_string(ctx.test)}

      assert {:ok, %File{} = file} =
               Files.update(ctx.uploaded_file, update_attrs)

      assert file.filename == Atom.to_string(ctx.test)
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{filename: nil}

      assert {:error, %Ecto.Changeset{}} =
               Files.update(ctx.uploaded_file, invalid_attrs)
    end

    test "deletes the file", ctx do
      assert {:ok, %File{}} = Files.delete(ctx.uploaded_file)

      assert_raise Ecto.NoResultsError, fn ->
        Files.get_file!(ctx.uploaded_file.id)
      end
    end

    test "returns a file changeset", ctx do
      assert %Ecto.Changeset{} = Files.change(ctx.uploaded_file)
    end
  end
end
