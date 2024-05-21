defmodule Runa.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating role entities.
  """
  alias Runa.Repo

  alias Runa.Roles.Role

  @roles Application.compile_env(:runa, :permissions)
  @default_attrs %{
    title: @roles[:owner]
  }

  @doc """
  Generate auxilary role
  """
  def create_aux_role(attrs \\ %{})

  def create_aux_role(%{test: _}) do
    {:ok, role} =
      %Role{}
      |> Role.changeset(@default_attrs)
      |> Repo.insert()

    %{role: role}
  end

  def create_aux_role(attrs) do
    attrs = Enum.into(attrs, @default_attrs)

    {:ok, role} =
      %Role{}
      |> Role.changeset(attrs)
      |> Repo.insert()

    {:ok, role}
  end
end
