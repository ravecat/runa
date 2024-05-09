defmodule Runa.TeamRoles.TeamRole do
  @moduledoc """
  Schema for team role, representing the relationship between a user, a team, and a role.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Accounts, Teams, Roles}

  schema "team_roles" do
    belongs_to :user, Accounts.User
    belongs_to :role, Roles.Role
    belongs_to :team, Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_team_role, attrs) do
    user_team_role
    |> cast(attrs, [
      :user_id,
      :team_id,
      :role_id
    ])
    |> validate_required([:user_id, :team_id, :role_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:role_id)
  end
end
