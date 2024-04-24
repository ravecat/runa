defmodule Runa.Permissions.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Permissions` context.
  """

  @doc """
  Generate a team_role.
  """
  def create_aux_team_role(
        %{
          test: _,
          team: %Runa.Teams.Team{} = team,
          user: %Runa.Accounts.User{} = user,
          role: %Runa.Permissions.Role{} = role
        } = attrs
      ) do
    {:ok, team_role} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        user_id: user.id,
        role_id: role.id
      })
      |> Runa.Permissions.create_team_role()

    %{team_role: team_role}
  end

  def create_aux_team_role(attrs) do
    {:ok, team_role} =
      attrs
      |> Enum.into(%{})
      |> Runa.Permissions.create_team_role()

    %{team_role: team_role}
  end

  def create_aux_role(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        title: "admin"
      })
      |> Runa.Permissions.create_role()

    %{role: role}
  end
end
