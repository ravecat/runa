defmodule Runa.Accounts.User do
  @moduledoc """
  User schema
  """

  use Runa, :schema

  alias Runa.Contributors.Contributor
  alias Runa.Teams.Team
  alias Runa.Tokens.Token

  typed_schema "users" do
    field(:email, :string)
    field(:uid, :string)
    field(:name, :string)
    field(:avatar, :string)
    field(:nickname, :string)
    has_many(:contributors, Contributor)
    has_many(:tokens, Token)
    many_to_many(:teams, Team, join_through: Contributor)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :uid, :avatar, :nickname, :email])
    |> validate_required([:uid, :email, :name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:email)
    |> unique_constraint(:uid)
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([
        :id,
        :email,
        :name,
        :avatar,
        :nickname,
        :inserted_at,
        :updated_at
      ])
      |> Map.update(:inserted_at, nil, fn
        dt when is_struct(dt, DateTime) -> dt_to_string(dt)
        other -> other
      end)
      |> Map.update(:updated_at, nil, fn
        dt when is_struct(dt, DateTime) -> dt_to_string(dt)
        other -> other
      end)
      |> Jason.Encode.map(opts)
    end
  end
end
