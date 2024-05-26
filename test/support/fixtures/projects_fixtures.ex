defmodule Runa.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Projects` context.
  """

  alias Runa.Projects

  import Runa.TeamsFixtures

  @doc """
  Generate a project.
  """
  def create_aux_project(attrs \\ %{}) do
    team = create_aux_team()

    default_attrs = %{
      description: "Some description",
      name: "Some name",
      team_id: team.id
    }

    {:ok, project} =
      attrs
      |> Enum.into(default_attrs)
      |> Projects.create_project()

    project
  end
end
