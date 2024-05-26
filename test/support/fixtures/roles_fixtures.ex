defmodule Runa.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating role entities.
  """
  alias Runa.{Roles.Role, Repo}

  @roles Application.compile_env(:runa, :permissions)

  @doc """
  Generate auxilary role
  """
  def create_aux_role(_attrs \\ %{}) do
    case Repo.get_by(Role, title: @roles[:owner]) do
      role = %Role{} ->
        role

      nil ->
        %Role{} |> Role.changeset(%{title: @roles[:owner]}) |> Repo.insert!()
    end
  end
end
