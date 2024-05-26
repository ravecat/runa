defmodule Runa.KeysTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :keys

  alias Runa.{Keys, Keys.Key}

  import Runa.{KeysFixtures, ProjectsFixtures}

  setup do
    key = create_aux_key()

    %{key: key}
  end

  describe "keys context" do
    test "returns all keys", ctx do
      assert Keys.list_keys() == [ctx.key]
    end

    test "returns the key with given id", ctx do
      assert Keys.get_key!(ctx.key.id) == ctx.key
    end

    test "creates a key with valid data" do
      project = create_aux_project()

      valid_attrs = %{
        name: "some name",
        description: "some description",
        project_id: project.id
      }

      assert {:ok, %Key{} = key} = Keys.create_key(valid_attrs)
      assert key.name == "some name"
      assert key.description == "some description"
    end

    test "returns error changeset during create with invalid data" do
      invalid_attrs = %{name: nil, description: nil}
      assert {:error, %Ecto.Changeset{}} = Keys.create_key(invalid_attrs)
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

      assert ctx.key == Keys.get_key!(ctx.key.id)
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
