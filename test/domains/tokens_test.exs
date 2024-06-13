defmodule Runa.TokensTest do
  @moduledoc false
  use Runa.DataCase

  @moduletag :tokens

  alias Runa.{Tokens, Tokens.Token}

  import Runa.Factory

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)

  setup do
    user = insert(:user)
    token = insert(:token, user: user)

    {:ok, token: token, user: user}
  end

  describe "tokens" do
    test "return all tokens", ctx do
      assert [token] = Tokens.get_tokens()

      assert token.id == ctx.token.id
    end

    test "return the token with given id", ctx do
      assert token = Tokens.get_token!(ctx.token.id)

      assert token.id == ctx.token.id
      assert token.access == ctx.token.access
      assert token.user_id == ctx.user.id
    end

    test "create a token with valid data", ctx do
      valid_attrs = %{access: @valid_access_levels[:read], user_id: ctx.user.id}

      assert {:ok, %Token{} = token} = Tokens.create_token(valid_attrs)
      assert token.access == @valid_access_levels[:read]
      assert String.length(token.token) == 32
      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, token.token)
    end

    test "return error changeset during creation with invalid data" do
      invalid_attrs = %{access: nil, token: nil}

      assert {:error, %Ecto.Changeset{}} = Tokens.create_token(invalid_attrs)
    end

    test "update the token with valid data", ctx do
      update_attrs = %{
        access: @valid_access_levels[:read]
      }

      assert {:ok, %Token{} = token} =
               Tokens.update_token(ctx.token, update_attrs)

      assert token.access == @valid_access_levels[:read]
    end

    test "return error changeset during update with invalid data", ctx do
      invalid_attrs = %{access: nil, token: nil}

      assert {:error, %Ecto.Changeset{}} =
               Tokens.update_token(ctx.token, invalid_attrs)
    end

    test "delete the token", ctx do
      assert {:ok, %Token{}} = Tokens.delete_token(ctx.token)

      assert_raise Ecto.NoResultsError, fn ->
        Tokens.get_token!(ctx.token.id)
      end
    end

    test "return a token changeset", ctx do
      assert %Ecto.Changeset{} = Tokens.change_token(ctx.token)
    end
  end
end
