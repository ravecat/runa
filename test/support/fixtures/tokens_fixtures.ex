defmodule Runa.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Tokens` context.
  """

  alias Runa.Tokens

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)
  @default_attrs %{
    access: @valid_access_levels[:read]
  }

  @doc """
  Generate a token.
  """
  def create_aux_token(attrs \\ %{})

  def create_aux_token(%{test: _} = attrs) do
    {:ok, token} =
      attrs
      |> Enum.into(@default_attrs)
      |> Map.put(:user_id, attrs.user.id)
      |> Tokens.create_token()

    %{token: token}
  end

  def create_aux_token(attrs) do
    {:ok, token} =
      attrs
      |> Enum.into(@default_attrs)
      |> Tokens.create_token()

    token
  end
end
