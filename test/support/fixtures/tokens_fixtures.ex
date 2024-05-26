defmodule Runa.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Tokens` context.
  """

  alias Runa.Tokens

  import Runa.AccountsFixtures

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)

  @doc """
  Generate a token.
  """
  def create_aux_token(attrs \\ %{}) do
    user = create_aux_user()

    {:ok, token} =
      attrs
      |> Enum.into(%{
        access: @valid_access_levels[:read],
        user_id: user.id
      })
      |> Tokens.create_token()

    token
  end
end
