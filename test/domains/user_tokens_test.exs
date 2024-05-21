defmodule Runa.UserTokensTest do
  @moduledoc false

  use Runa.DataCase

  alias Runa.{UserTokens.UserToken, UserTokens}

  import Runa.{
    UserTokensFixtures,
    AccountsFixtures,
    TokensFixtures,
    RolesFixtures,
    TeamsFixtures
  }

  @invalid_attrs %{}

  describe "user_tokens" do
    setup [
      :create_aux_role,
      :create_aux_team,
      :create_aux_user,
      :create_aux_token
    ]

    test "returns all user tokens", ctx do
      user_token =
        create_aux_user_token(%{
          user_id: ctx.user.id,
          token_id: ctx.token.id
        })

      assert UserTokens.get_user_tokens() == [user_token]
    end

    test "returns the user token with given id", ctx do
      user_token =
        create_aux_user_token(%{
          user_id: ctx.user.id,
          token_id: ctx.token.id
        })

      assert UserTokens.get_user_token!(user_token.id) == user_token
    end

    test "creates a user_token with valid data", ctx do
      valid_attrs = %{user_id: ctx.user.id, token_id: ctx.token.id}

      assert {:ok, %UserToken{}} = UserTokens.create_user_token(valid_attrs)
    end

    test "returns error changeset after creation with invalid data " do
      assert {:error, %Ecto.Changeset{}} =
               UserTokens.create_user_token(@invalid_attrs)
    end

    test "deletes the user token", ctx do
      user_token =
        create_aux_user_token(%{user_id: ctx.user.id, token_id: ctx.token.id})

      assert {:ok, %UserToken{}} = UserTokens.delete_user_token(user_token)

      assert_raise Ecto.NoResultsError, fn ->
        UserTokens.get_user_token!(user_token.id)
      end
    end

    test "returns a user token changeset", ctx do
      user_token =
        create_aux_user_token(%{user_id: ctx.user.id, token_id: ctx.token.id})

      assert %Ecto.Changeset{} = UserTokens.change_user_token(user_token)
    end
  end
end
