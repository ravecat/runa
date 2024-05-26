defmodule Runa.KeysFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Keys` context.
  """

  alias Runa.Keys

  import Runa.{ProjectsFixtures, TeamsFixtures}

  @doc """
  Generate a key.
  """
  def create_aux_key(attrs \\ %{}) do
    team = create_aux_team()
    project = create_aux_project(%{team_id: team.id})

    default_attrs = %{
      name: "key name",
      description: "key description",
      project_id: project.id
    }

    {:ok, key} =
      attrs
      |> Enum.into(default_attrs)
      |> Keys.create_key()

    key
  end
end
