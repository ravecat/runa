defmodule Runa.ContributorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the team roles context.
  """
  alias Runa.Contributors

  import Runa.{AccountsFixtures, TeamsFixtures, RolesFixtures}

  @doc """
  Generate auxilary team role.
  """
  def create_aux_contributor(attrs \\ %{}) do
    user = create_aux_user()
    team = create_aux_team()
    role = create_aux_role()

    {:ok, contributor} =
      attrs
      |> Enum.into(%{
        team_id: team.id,
        user_id: user.id,
        role_id: role.id
      })
      |> Contributors.create_contributor()

    contributor
  end
end
