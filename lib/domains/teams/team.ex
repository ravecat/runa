defmodule Runa.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :title, :string

    has_many :team_roles, Runa.Permissions.TeamRole

    many_to_many :users, Runa.Accounts.User,
      join_through: Runa.Permissions.TeamRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
