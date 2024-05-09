defmodule Runa.Teams.Team do
  @moduledoc """
  The schema for teams, which are groups of users
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :title, :string

    has_many :team_roles, Runa.TeamRoles.TeamRole

    many_to_many :users, Runa.Accounts.User,
      join_through: Runa.TeamRoles.TeamRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
