defmodule Runa.TokenGeneratorTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :generators

  import Runa.TokenGenerator

  describe "token generator (URL type)" do
    test "generates token with default length" do
      token = generate_token()

      assert String.length(token) == 32
    end

    test "generates token with with valid symbols" do
      token = generate_token(length: 32)

      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, token)
    end

    test "generates token with specified length" do
      token = generate_token(length: 64)

      assert String.length(token) == 64
    end
  end

  describe "token generator (schema type)" do
    test "generates token with default length" do
      token = generate_token(type: :schema)

      assert String.length(token) == 32
    end

    test "generates token with with valid symbols" do
      token = generate_token(type: :schema)

      assert Regex.match?(~r/^[A-Za-z_][A-Za-z0-9_]*$/, token)
    end

    test "generates token with specified length" do
      token = generate_token(type: :schema, length: 60)

      assert String.length(token) == 60
    end

    test "raises error if lenght more than 63 symbols" do
      assert_raise ArgumentError, fn ->
        generate_token(type: :schema, length: 64)
      end
    end
  end
end
