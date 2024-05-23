defmodule Runa.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Files` context.
  """

  @default_attrs %{
    filename: "some filename"
  }

  @doc """
  Generate a file.
  """
  def create_aux_file(attrs \\ %{})

  def create_aux_file(%{test: _, project: project} = attrs) do
    {:ok, file} =
      attrs
      |> Enum.into(@default_attrs)
      |> Map.put(:project_id, project.id)
      |> Runa.Files.create_file()

    %{uploaded_file: file}
  end

  def create_aux_file(attrs) do
    {:ok, file} =
      attrs
      |> Enum.into(@default_attrs)
      |> Runa.Files.create_file()

    file
  end
end
