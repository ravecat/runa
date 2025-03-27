defmodule Runa.KeysTest do
  use Runa.DataCase, async: true

  @moduletag :keys

  alias Runa.Keys
  alias Runa.Keys.Key

  setup do
    team = insert(:team)

    project =
      insert(:project, base_language: fn -> build(:language) end, team: team)

    file = insert(:file, project: project)
    key = insert(:key, file: file)

    {:ok, key: key, team: team, localization_file: file}
  end

  describe "keys context" do
    test "returns all keys", ctx do
      assert {:ok, {keys, _}} = Keys.index()
      assert Enum.any?(keys, fn key -> key.id == ctx.key.id end)
    end

    test "returns the key with given id", ctx do
      assert {:ok, %Key{} = key} = Keys.get(ctx.key.id)
      assert key.id == ctx.key.id
    end

    test "creates a key with valid data", ctx do
      valid_attrs = %{
        name: "some name",
        description: "some description",
        file_id: ctx.localization_file.id
      }

      assert {:ok, %Key{} = key} = Keys.create(valid_attrs)
      assert key.name == "some name"
      assert key.description == "some description"
    end

    test "returns error changeset during create with invalid data" do
      invalid_attrs = %{name: nil, description: nil}
      assert {:error, %Ecto.Changeset{}} = Keys.create(invalid_attrs)
    end

    test "updates the key with valid data", ctx do
      update_attrs = %{
        name: "some updated name",
        description: "some updated description"
      }

      assert {:ok, %Key{} = key} = Keys.update(ctx.key, update_attrs)
      assert key.name == "some updated name"
      assert key.description == "some updated description"
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} = Keys.update(ctx.key, invalid_attrs)
    end

    test "deletes the key", ctx do
      assert {:ok, %Key{}} = Keys.delete(ctx.key)
      assert {:error, %Ecto.NoResultsError{}} = Keys.get(ctx.key.id)
    end

    test "returns a key changeset", ctx do
      assert %Ecto.Changeset{} = Keys.change(ctx.key)
    end
  end
end
