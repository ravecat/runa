defmodule Runa.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Files` context.
  """

  import Runa.ProjectsFixtures

  @doc """
  Generate a file.
  """
  def create_aux_file(attrs \\ %{}) do
    project = create_aux_project()

    default_attrs = %{
      filename: "some filename",
      project_id: project.id
    }

    {:ok, file} =
      attrs
      |> Enum.into(default_attrs)
      |> Map.put(:project_id, project.id)
      |> Runa.Files.create_file()

    file
  end
end
