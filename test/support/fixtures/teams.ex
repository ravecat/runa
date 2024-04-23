defmodule Runa.Teams.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def create_aux_team(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        title: "team title"
      })
      |> Runa.Teams.create_team()

    %{team: team}
  end
end
