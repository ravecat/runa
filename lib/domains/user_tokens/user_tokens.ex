defmodule Runa.UserTokens do
  @moduledoc """
  The UserTokens context.
  """

  import Ecto.Query, warn: false

  alias Runa.Repo
  alias Runa.UserTokens.UserToken

  @doc """
  Returns the list of user_tokens.
  """
  def get_user_tokens do
    Repo.all(UserToken)
  end

  @doc """
  Gets a single user_token.

  Raises if the user token does not exist.
  """
  def get_user_token!(%{user_id: user_id, token_id: token_id}) do
    Repo.get_by!(UserToken, user_id: user_id, token_id: token_id)
  end

  def get_user_token!(id), do: Repo.get!(UserToken, id)

  @doc """
  Creates a user_token.
  """
  def create_user_token(attrs \\ %{}) do
    %UserToken{}
    |> UserToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a user token.
  """
  def delete_user_token(%UserToken{} = user_token) do
    Repo.delete(user_token)
  end

  @doc """
  Returns a data structure for tracking user_token changes.
  """
  def change_user_token(%UserToken{} = user_token, attrs \\ %{}) do
    UserToken.changeset(user_token, attrs)
  end
end
