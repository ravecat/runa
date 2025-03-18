defmodule Runa.TokensTest do
  @moduledoc false
  use Runa.DataCase

  @moduletag :tokens

  alias Runa.Tokens
  alias Runa.Tokens.Token

  setup do
    user = insert(:user)
    scope = build_scope(user)
    token = insert(:token, user: user, access: :read)

    {:ok, token: token, user: user, scope: scope}
  end

  describe "tokens context" do
    test "returns all entities", ctx do
      assert data = Tokens.index(ctx.scope)

      Enum.each(data, &assert(is_struct(&1, Token)))
    end

    test "creates entity with valid data", ctx do
      assert {:ok, %Token{} = token} =
               Tokens.create(ctx.scope, %{
                 access: :read,
                 user_id: ctx.user.id,
                 title: Atom.to_string(ctx.test)
               })

      assert token.access == :read
      assert token.user_id == ctx.user.id
      assert token.hash != nil
    end

    test "sends pubsub event after create", ctx do
      Tokens.subscribe(ctx.scope)

      {:ok, data} =
        Tokens.create(ctx.scope, %{
          access: :read,
          user_id: ctx.user.id,
          title: Atom.to_string(ctx.test)
        })

      assert_receive %Events.TokenCreated{data: ^data}
    end

    test "returns error changeset during creation with invalid data", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Tokens.create(ctx.scope, %{access: nil, user_id: ctx.user.id})
    end

    test "updates access", ctx do
      token = insert(:token, access: :read, user: ctx.user)

      assert {:ok, %Token{} = token} =
               Tokens.update(ctx.scope, token, %{access: :write})

      assert token.access == :write
    end

    test "sends pubsub event after update", ctx do
      token = insert(:token, access: :read, user: ctx.user)

      Tokens.subscribe(ctx.scope)

      assert {:ok, data} = Tokens.update(ctx.scope, token, %{access: :write})

      assert_receive %Events.TokenUpdated{data: ^data}
    end

    test "ignores fields other than access on update", ctx do
      user = insert(:user)

      assert {:ok, %Token{} = token} =
               Tokens.update(ctx.scope, ctx.token, %{
                 access: :write,
                 user_id: user.id
               })

      assert token.access == :write
      assert token.user_id == ctx.user.id
    end

    test "returns error changeset during update with invalid data", ctx do
      assert {:error, %Ecto.Changeset{}} =
               Tokens.update(ctx.scope, ctx.token, %{access: nil})
    end

    test "deletes entity", ctx do
      assert {:ok, %Token{}} = Tokens.delete(ctx.scope, ctx.token)

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
