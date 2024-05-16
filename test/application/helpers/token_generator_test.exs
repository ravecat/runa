defmodule Runa.TokenGeneratorTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :generators

  import Runa.TokenGenerator

  describe "token generator" do
    test "generates token with default length" do
      token = generate_token()

      assert String.length(token) == 32
    end

    test "generates token with with valid symbols" do
      token = generate_token()

      assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, token)
    end

    test "generates token with specified length" do
      token = generate_token(64)

      assert String.length(token) == 64
    end
  end
end
