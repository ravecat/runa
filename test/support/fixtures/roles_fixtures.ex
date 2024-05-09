defmodule Runa.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating role entities.
  """
  alias Runa.Repo

  alias Runa.Roles.Role

  @roles Application.compile_env(:runa, :permissions)

  @doc """
  Generate auxilary role
  """
  def create_aux_role(attrs \\ %{})

  def create_aux_role(%{test: _}) do
    {:ok, role} =
      %Role{}
      |> Role.changeset(%{
        title: @roles[:owner]
      })
      |> Repo.insert()

    %{role: role}
  end

  def create_aux_role(attrs) do
    attrs =
      Enum.into(attrs, %{
        title: @roles[:owner]
      })

    {:ok, role} =
      %Role{}
      |> Role.changeset(attrs)
      |> Repo.insert()

    {:ok, role}
  end
end
