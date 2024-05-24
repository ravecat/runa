defmodule Runa.KeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Keys` context.
  """

  alias Runa.Keys

  @default_attrs %{
    name: "some name",
    description: "some description"
  }

  @doc """
  Generate a key.
  """
  def create_aux_key(attrs \\ %{})

  def create_aux_key(%{test: _} = attrs) do
    {:ok, key} =
      attrs
      |> Enum.into(@default_attrs)
      |> Enum.into(%{project_id: attrs.project.id})
      |> Keys.create_key()

    %{key: key}
  end

  def create_aux_key(attrs) do
    {:ok, key} =
      attrs
      |> Enum.into(@default_attrs)
      |> Keys.create_key()

    key
  end
end
