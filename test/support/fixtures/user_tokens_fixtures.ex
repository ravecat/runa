defmodule Runa.UserTokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.UserTokens` context.
  """

  alias Runa.{Accounts, UserTokens, Tokens}

  @doc """
  Generate a user token.
  """
  def create_aux_user_token(attrs \\ %{})

  def create_aux_user_token(
        %{
          test: _,
          user: %Accounts.User{} = user,
          token: %Tokens.Token{} = token
        } = attrs
      ) do
    {:ok, user_token} =
      attrs
      |> Enum.into(%{
        user_id: user.id,
        token_id: token.id
      })
      |> UserTokens.create_user_token()

    %{user_token: user_token}
  end

  def create_aux_user_token(attrs) do
    {:ok, user_token} =
      attrs
      |> Enum.into(%{})
      |> UserTokens.create_user_token()

    user_token
  end
end
