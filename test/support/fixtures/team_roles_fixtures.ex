defmodule Runa.ContributorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the team roles context.
  """

  alias Runa.{Contributors, Teams, Roles, Accounts}

  @doc """
  Generate auxilary team role.
  """
  def create_aux_contributor(
        %{
          test: _,
          team: %Teams.Team{} = team,
          user: %Accounts.User{} = user,
          role: %Roles.Role{} = role
        } = attrs
      ) do
    {:ok, contributor} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        user_id: user.id,
        role_id: role.id
      })
      |> Contributors.create_contributor()

    %{contributor: contributor}
  end

  def create_aux_contributor(attrs) do
    {:ok, contributor} =
      attrs
      |> Enum.into(%{})
      |> Contributors.create_contributor()

    contributor
  end
end
