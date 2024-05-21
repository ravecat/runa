defmodule Runa.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Teams` context.
  """

  @default_attrs %{
    title: "team title"
  }

  @doc """
  Generate a team.
  """
  def create_aux_team(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(@default_attrs)
      |> Runa.Teams.create_team()

    %{team: team}
  end
end
