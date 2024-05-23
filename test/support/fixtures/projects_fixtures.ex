defmodule Runa.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Projects` context.
  """

  alias Runa.Projects

  @default_attrs %{
    description: "Some description",
    name: "Some name"
  }

  @doc """
  Generate a project.
  """
  def create_aux_project(attrs \\ %{})

  def create_aux_project(%{test: test} = attrs) do
    {:ok, project} =
      attrs
      |> Enum.into(@default_attrs)
      |> Enum.into(%{
        description: Atom.to_string(test),
        name: Atom.to_string(test)
      })
      |> Projects.create_project()

    %{project: project}
  end

  def create_aux_project(attrs) do
    {:ok, project} =
      attrs
      |> Enum.into(@default_attrs)
      |> Projects.create_project()

    project
  end
end
