defmodule Runa.Permissions.TeamRole do
  @moduledoc """
  TeamRole schema for permissions, representing the relationship between a user, a team, and a role.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_roles" do
    belongs_to :user, Runa.Accounts.User
    belongs_to :role, Runa.Permissions.Role
    belongs_to :team, Runa.Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_team_role, attrs) do
    user_team_role
    |> cast(attrs, [:user_id, :team_id, :role_id, :updated_at])
    |> validate_required([:user_id, :team_id, :role_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:role_id)
  end
end
