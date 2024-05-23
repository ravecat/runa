defmodule Runa.Tokens.Token do
  @moduledoc """
  The api tokens  schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.Accounts.User

  @valid_access_levels Application.compile_env(:runa, :token_access_levels)
                       |> Map.values()

  schema "tokens" do
    field :token, :string
    field :access, :integer
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:access, :user_id])
    |> validate_required([:access, :token, :user_id])
    |> validate_inclusion(:access, @valid_access_levels)
    |> foreign_key_constraint(:user_id)
  end
end
