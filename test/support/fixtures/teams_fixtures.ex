defmodule Runa.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Teams` context.
  """

  alias Runa.Teams

  @doc """
  Generate a team.
  """
  def create_aux_team(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        title: "team title"
      })
      |> Teams.create_team()

    team
  end
end
