defmodule Runa.AccountsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :accounts

  alias Runa.{Accounts, Accounts.User}

  import Runa.{AccountsFixtures, TeamsFixtures, RolesFixtures}

  @invalid_attrs %{uid: nil, email: nil}
  @valid_attrs %{
    name: "some name",
    uid: "xxx",
    email: "peter.parker@mail.com"
  }

  describe "users" do
    setup [:create_aux_role, :create_aux_user, :create_aux_team]

    test "returns all users", %{user: user} do
      assert Accounts.get_users() == [user]
    end

    test "returns the user with given id", %{
      user: user
    } do
      assert Accounts.get_user!(user.id) == user
    end

    test "creates a user with valid data" do
      assert {:ok, %User{} = user} = Accounts.create_or_find_user(@valid_attrs)

      assert user.name == "some name"
    end

    test "returns error during creation a user with invalid data" do
      assert {:error, %Ecto.Changeset{} = changeset} =
               Accounts.create_or_find_user(@invalid_attrs)

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

    test "updates a user with invalid data",
         %{user: user} do
      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user(user, @invalid_attrs)

      assert user == Accounts.get_user!(user.id)
    end

    test "deletes the user", %{user: user} do
      assert {:ok, %User{}} = Accounts.delete_user(user)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end
    end

    test "returns a user changeset", %{
      user: user
    } do
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
