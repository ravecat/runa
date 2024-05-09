defmodule Runa.TokensTest do
  @moduledoc false
  use Runa.DataCase

  @moduletag :tokens

  alias Runa.Tokens
  alias Runa.Tokens.Token

  import Runa.TokensFixtures

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)
  @invalid_attrs %{access: nil, token: nil}

  describe "tokens" do
    test "list_tokens/0 returns all tokens" do
      token = create_aux_token()
      assert Tokens.list_tokens() == [token]
    end

    test "get_token!/1 returns the token with given id" do
      token = create_aux_token()
      assert Tokens.get_token!(token.id) == token
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{access: @valid_access_levels[:read]}

      assert {:ok, %Token{} = token} = Tokens.create_token(valid_attrs)
      assert token.access == @valid_access_levels[:read]
      assert String.length(token.token) == 64
      assert Regex.match?(~r/^[a-z0-9]+$/, token.token)
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tokens.create_token(@invalid_attrs)
    end

    test "update_token/2 with valid data updates the token" do
      token = create_aux_token()

      update_attrs = %{
        access: @valid_access_levels[:read],
        token: "some updated token"
      }

      assert {:ok, %Token{} = token} = Tokens.update_token(token, update_attrs)
      assert token.access == @valid_access_levels[:read]
      assert String.length(token.token) == 64
      assert Regex.match?(~r/^[a-z0-9]+$/, token.token)
    end

    test "update_token/2 with invalid data returns error changeset" do
      token = create_aux_token()

      assert {:error, %Ecto.Changeset{}} =
               Tokens.update_token(token, @invalid_attrs)

      assert token == Tokens.get_token!(token.id)
    end

    test "delete_token/1 deletes the token" do
      token = create_aux_token()
      assert {:ok, %Token{}} = Tokens.delete_token(token)
      assert_raise Ecto.NoResultsError, fn -> Tokens.get_token!(token.id) end
    end

    test "change_token/1 returns a token changeset" do
      token = create_aux_token()
      assert %Ecto.Changeset{} = Tokens.change_token(token)
    end
  end
end
