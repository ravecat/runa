defmodule Runa.Services.Avatar do
  @moduledoc """
  Service for generating avatars using DiceBear
  """

  @base_url "https://api.dicebear.com/9.x"
  @styles [:initials, :shapes, :identicon, :thumbs]

  @doc """
  Generates avatar URL with options.

  ## Options
    * `:style` - Avatar style (default: :identicon)
    #{inspect(@styles)}
  """
  @spec generate_url(binary, keyword) :: String.t()
  def generate_url(seed, opts \\ [])

  def generate_url(seed, opts) when is_binary(seed) do
    style = Keyword.get(opts, :style, :thumbs)

    if style in @styles do
      "#{@base_url}/#{style}/svg?seed=#{URI.encode(seed)}"
    else
      raise ArgumentError,
            "Invalid style: #{inspect(style)}. Allowed styles: #{inspect(@styles)}"
    end
  end

  def generate_url(_, _) do
    raise ArgumentError, "Invalid seed: seed must be a string"
  end

  def generate_random_url(opts \\ []) do
    ?a..?z
    |> Enum.concat(?A..?Z)
    |> Enum.take_random(8)
    |> List.to_string()
    |> generate_url(opts)
  end
end
