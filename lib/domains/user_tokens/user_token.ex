defmodule Runa.UserTokens.UserToken do
  @moduledoc """
  Schema for user token, representing the relationship between a user and a token.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Accounts, Tokens}

  schema "user_tokens" do
    belongs_to :user, Accounts.User
    belongs_to :token, Tokens.Token

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [
      :user_id,
      :token_id
    ])
    |> validate_required([:user_id, :token_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:token_id)
  end
end
