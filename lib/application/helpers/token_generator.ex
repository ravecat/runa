defmodule Runa.TokenGenerator do
  @moduledoc """
  Utility module for generating tokens and hashes.
  """

  @default_opts [
    length: 32,
    type: :alphanumeric
  ]

  @doc """
  Generates a random token based on the specified options.

  ## Options

    * `:length` - The length of the token (default: 32)
    * `:type` - The type of token (default: :alphanumeric)
      * `:alphanumeric` - generates a token with alphanumeric characters
      * `:schema` - generates a token that can be used as a schema name

  ## Examples

      # Generate a standard alphanumeric token (32 characters)
      iex> Runa.TokenGenerator.generate_token()
      "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0"

      # Generate a standard alphanumeric token (16 characters)
      iex> Runa.TokenGenerator.generate_token(length: 16)
      "a1b2c3d4e5f6g7"

      # Generate a schema token (63 characters long by default)
      iex> Runa.TokenGenerator.generate_token(type: :schema)
      "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0"

  """
  def generate_token(opts \\ []) do
    opts = Keyword.merge(@default_opts, opts)
    length = Keyword.get(opts, :length)
    type = Keyword.get(opts, :type)

    case type do
      :schema -> generate_schema_token(length)
      _ -> generate_alphanumeric_token(length)
    end
  end

  defp generate_alphanumeric_token(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  defp generate_schema_token(length) when length < 63 do
    characters = ?A..?Z |> Enum.concat(?a..?z) |> Enum.concat(?0..?9)

    head = [Enum.random(?a..?z)]

    rest =
      for _ <- 1..(length - 1), into: [] do
        Enum.random(characters)
      end

    (head ++ rest) |> List.to_string()
  end

  defp generate_schema_token(_length) do
    raise ArgumentError, "Schema token length must be 63 characters or less"
  end
end
