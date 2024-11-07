defmodule Runa.AccountsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :accounts
  @roles Application.compile_env(:runa, :permissions)

  alias Runa.Accounts
  alias Runa.Accounts.User

  setup do
    user = insert(:user)
    {:ok, user: user}
  end

  describe "users" do
    test "returns all users", ctx do
      assert Accounts.get_users() == [ctx.user]
    end

    test "returns the user with given id", ctx do
      user = Accounts.get_user!(ctx.user.id)
      assert user.id == ctx.user.id
    end

    test "creates a user with valid data" do
      insert(:role, title: @roles[:owner])

      valid_attrs = %{
        name: "some name",
        uid: "xxx",
        email: "peter.parker@mail.com"
      }

      assert {:ok, %User{} = user} = Accounts.create_or_find_user(valid_attrs)

      assert user.name == valid_attrs.name
      assert user.uid == valid_attrs.uid
      assert user.email == valid_attrs.email
    end

    test "returns error during creation a user with invalid data" do
      invalid_attrs = %{uid: nil, email: nil}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.create_or_find_user(invalid_attrs)

      assert changeset.errors == [
               uid: {"can't be blank", [validation: :required]},
               email: {"can't be blank", [validation: :required]}
             ]
    end

    test "updates the user with valid data", ctx do
      update_attrs = %{name: "some updated name"}

      assert {:ok, %User{} = user} =
               Accounts.update_user(ctx.user, update_attrs)

      assert user.name == "some updated name"
    end

    test "updates a user with invalid data", ctx do
      invalid_attrs = %{uid: nil, email: nil}

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(ctx.user, invalid_attrs)
    end

    test "deletes the user", ctx do
      assert {:ok, %User{}} = Accounts.delete_user(ctx.user)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(ctx.user.id)
      end
    end

    test "returns a user changeset", ctx do
      assert %Ecto.Changeset{} = Accounts.change_user(ctx.user)
    end
  end
end
