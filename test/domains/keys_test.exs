defmodule Runa.KeysTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :keys

  alias Runa.Keys
  alias Runa.Keys.Key

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    key = insert(:key, project: project)

    {:ok, key: key, team: team}
  end

  describe "keys context" do
    test "returns all keys", ctx do
      assert [key] = Keys.list_keys()
      assert key.id == ctx.key.id
    end

    test "returns the key with given id", ctx do
      assert key = Keys.get_key!(ctx.key.id)
      assert key.id == ctx.key.id
    end

    test "creates a key with valid data", ctx do
      project = insert(:project, team: ctx.team)

      valid_attrs = %{
        name: "some name",
        description: "some description",
        project_id: project.id
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

      assert {:ok, %Key{} = key} = Keys.update_key(ctx.key, update_attrs)
      assert key.name == "some updated name"
      assert key.description == "some updated description"
    end

    test "returns error changeset during update with invalid data", ctx do
      invalid_attrs = %{name: nil, description: nil}

      assert {:error, %Ecto.Changeset{}} =
               Keys.update_key(ctx.key, invalid_attrs)
    end

    test "deletes the key", ctx do
      assert {:ok, %Key{}} = Keys.delete_key(ctx.key)
      assert_raise Ecto.NoResultsError, fn -> Keys.get_key!(ctx.key.id) end
    end

    test "returns a key changeset", ctx do
      assert %Ecto.Changeset{} = Keys.change_key(ctx.key)
    end
  end
end
