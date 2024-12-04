defmodule Runa.TokensTest do
  @moduledoc false
  use Runa.DataCase

  @moduletag :tokens

  alias Runa.Tokens
  alias Runa.Tokens.Token

  setup do
    user = insert(:user)
    token = insert(:token, user: user, access: :read)

    {:ok, token: token, user: user}
  end

  describe "tokens context" do
    test "returns all entities", ctx do
      assert data = Tokens.index(ctx.user)

      Enum.each(data, &assert(is_struct(&1, Token)))
    end

    test "creates entity with valid data", ctx do
      assert {:ok, %Token{} = token} =
               Tokens.create(%{
                 access: :read,
                 user_id: ctx.user.id,
                 title: Atom.to_string(ctx.test)
               })

      assert token.access == :read
      assert token.user_id == ctx.user.id
      assert token.hash != nil
    end

    test "returns error changeset during creation with invalid data", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Tokens.create(%{access: nil, user_id: ctx.user.id})
    end

    test "updates access", ctx do
      token = insert(:token, access: :read, user: ctx.user)

      assert {:ok, %Token{} = token} =
               Tokens.update(token, %{access: :write})

      assert token.access == :write
    end

    test "ignores fields other than access on update", ctx do
      user = insert(:user)

      assert {:ok, %Token{} = token} =
               Tokens.update(ctx.token, %{access: :write, user_id: user.id})

      assert token.access == :write
      assert token.user_id == ctx.user.id
    end

    test "returns error changeset during update with invalid data", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Tokens.update(ctx.token, %{access: nil})
    end

    test "deletes entity", ctx do
      assert {:ok, %Token{}} = Tokens.delete(ctx.token)

      assert Repo.get(Token, ctx.token.id) == nil
    end

    test "returns changeset", ctx do
      assert %Ecto.Changeset{} = Tokens.change(ctx.token)
    end
  end

  describe "token generation" do
    test "generates token with required length" do
      token = Tokens.generate()

      assert String.length(token) == 32
    end

    test "generates token with url-safe symbols" do
      token = Tokens.generate()

      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, token)
    end
  end
end
