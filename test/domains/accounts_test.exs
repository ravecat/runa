defmodule Runa.AccountsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :accounts

  alias Runa.Accounts
  alias Runa.Accounts.User

  setup do
    user = insert(:user)

    {:ok, user: user}
  end

  describe "users" do
    test "returns all entities", ctx do
      data = Accounts.index()

      Enum.each(data, &assert(is_struct(&1, User)))
    end

    @tag :only
    test "returns the entity with given id", ctx do
      assert {:ok, entity} = Accounts.get(ctx.user.id)

      assert entity.id == ctx.user.id
    end

    test "creates an entity with valid data" do
      valid_attrs = %{
        name: "some name",
        uid: "xxx",
        email: "peter.parker@mail.com"
      }

      assert {:ok, %User{} = entity} = Accounts.create_or_find(valid_attrs)

      assert entity.name == valid_attrs.name
      assert entity.uid == valid_attrs.uid
      assert entity.email == valid_attrs.email
    end

    test "returns error during creation with invalid data" do
      invalid_attrs = %{uid: nil, email: nil}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.create_or_find(invalid_attrs)

      assert changeset.errors == [
               uid: {"can't be blank", [validation: :required]},
               email: {"can't be blank", [validation: :required]}
             ]
    end

    test "updates the entity with valid data", ctx do
      update_attrs = %{name: "some updated name"}

      assert {:ok, %User{} = entity} =
               Accounts.update(ctx.user, update_attrs)

      assert entity.name == "some updated name"
    end

    test "updates with invalid data returns error", ctx do
      invalid_attrs = %{uid: nil, email: nil}

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update(ctx.user, invalid_attrs)
    end

    test "deletes the entity", ctx do
      assert {:ok, %User{}} = Accounts.delete(ctx.user)

      assert {:error, %Ecto.NoResultsError{}} = Accounts.get(ctx.user.id)
    end

    test "returns an entity changeset", ctx do
      assert %Ecto.Changeset{} = Accounts.change(ctx.user)
    end
  end
end
