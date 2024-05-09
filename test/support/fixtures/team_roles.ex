defmodule Runa.TeamRoles.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the team roles context.
  """

  alias Runa.{TeamRoles, Teams, Roles, Accounts}

  @doc """
  Generate auxilary team role.
  """
  def create_aux_team_role(
        %{
          test: _,
          team: %Teams.Team{} = team,
          user: %Accounts.User{} = user,
          role: %Roles.Role{} = role
        } = attrs
      ) do
    {:ok, team_role} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        user_id: user.id,
        role_id: role.id
      })
      |> TeamRoles.create_team_role()

    %{team_role: team_role}
  end

  def create_aux_team_role(attrs) do
    {:ok, team_role} =
      attrs
      |> Enum.into(%{})
      |> TeamRoles.create_team_role()

    {:ok, team_role}
  end
end
