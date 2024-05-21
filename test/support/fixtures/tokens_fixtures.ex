defmodule Runa.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Tokens` context.
  """

  alias Runa.Tokens

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)

  @doc """
  Generate a token.
  """
  def create_aux_token(attrs \\ %{})

  def create_aux_token(
        %{
          test: _,
          user: user
        } = attrs
      ) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        access: @valid_access_levels[:read],
        user_id: user.id
      })
      |> Tokens.create_token()

    %{token: token}
  end

  def create_aux_token(attrs) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        access: @valid_access_levels[:read]
      })
      |> Tokens.create_token()

    token
  end
end
