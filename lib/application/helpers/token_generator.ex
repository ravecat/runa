defmodule Runa.TokenGenerator do
  @moduledoc """
  Utility module for generating tokens and hashes.
  """

  @doc """
  Generates a random token of the specified length.
  """
  def generate_token(length \\ 32) when is_integer(length) and length > 0 do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end
end
