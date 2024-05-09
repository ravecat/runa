defmodule Runa.Accounts.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{TeamRoles, Teams}

  schema "users" do
    field :email, :string
    field :uid, :string
    field :name, :string
    field :avatar, :string
    field :nickname, :string

    has_many :team_roles, TeamRoles.TeamRole

    many_to_many :teams, Teams.Team, join_through: TeamRoles.TeamRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :uid, :avatar, :nickname, :email])
    |> validate_required([:uid, :email])
    |> unique_constraint(:email)
    |> unique_constraint(:uid)
  end
end
