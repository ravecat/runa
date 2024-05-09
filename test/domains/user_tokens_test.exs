defmodule Runa.UserTokensTest do
  @moduledoc false
  use Runa.DataCase

  alias Runa.UserTokens
  alias Runa.UserTokens.UserToken

  import Runa.UserTokensFixtures
  import Runa.Accounts.Fixtures
  import Runa.TokensFixtures

  @invalid_attrs %{}

  describe "user_tokens" do
    setup [:create_aux_user, :create_aux_token]

    test "get_user_tokens/0 returns all user_tokens", ctx do
      user_token =
        create_aux_user_token(%{
          user_id: ctx.user.id,
          token_id: ctx.token.id
        })

      assert UserTokens.get_user_tokens() == [user_token]
    end

    test "get_user_token!/1 returns the user_token with given id", ctx do
      user_token =
        create_aux_user_token(%{
          user_id: ctx.user.id,
          token_id: ctx.token.id
        })

      assert UserTokens.get_user_token!(user_token.id) == user_token
    end

    test "create_user_token/1 with valid data creates a user_token", ctx do
      valid_attrs = %{user_id: ctx.user.id, token_id: ctx.token.id}

      assert {:ok, %UserToken{}} = UserTokens.create_user_token(valid_attrs)
    end

    test "create_user_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               UserTokens.create_user_token(@invalid_attrs)
    end

    test "delete_user_token/1 deletes the user_token", ctx do
      user_token =
        create_aux_user_token(%{user_id: ctx.user.id, token_id: ctx.token.id})

      assert {:ok, %UserToken{}} = UserTokens.delete_user_token(user_token)

      assert_raise Ecto.NoResultsError, fn ->
        UserTokens.get_user_token!(user_token.id)
      end
    end

    test "change_user_token/1 returns a user_token changeset", ctx do
      user_token =
        create_aux_user_token(%{user_id: ctx.user.id, token_id: ctx.token.id})

      assert %Ecto.Changeset{} = UserTokens.change_user_token(user_token)
    end
  end
end
