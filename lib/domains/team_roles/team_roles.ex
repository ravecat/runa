defmodule Runa.TeamRoles do
  @moduledoc """
  The team role context.
  """

  import Ecto.Query, warn: false

  alias Runa.Repo

  alias Runa.TeamRoles.TeamRole

  @doc """
  Returns the list of team_roles.

  ## Examples

      iex> get_team_roles()
      [%TeamRole{}, ...]

  """
  def get_team_roles do
    Repo.all(TeamRole)
  end

  @doc """
  Gets a single team_role.

  Raises `Ecto.NoResultsError` if the Team role does not exist.

  ## Examples

      iex> get_team_role!(123)
      %TeamRole{}

      iex> get_team_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_role!(%{
        team_id: team_id,
        role_id: role_id,
        user_id: user_id
      }),
      do:
        Repo.get_by!(TeamRole,
          team_id: team_id,
          role_id: role_id,
          user_id: user_id
        )

  @doc """
  Creates a team_role.

  ## Examples

      iex> create_team_role(%{field: value})
      {:ok, %TeamRole{}}

      iex> create_team_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_role(attrs \\ %{}) do
    %TeamRole{}
    |> TeamRole.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_role.

  ## Examples

      iex> update_team_role(team_role, %{field: new_value})
      {:ok, %TeamRole{}}

      iex> update_team_role(team_role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_team_role(%TeamRole{} = team_role, attrs) do
    team_role
    |> TeamRole.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_role.

  ## Examples

      iex> delete_team_role(team_role)
      {:ok, %TeamRole{}}

      iex> delete_team_role(team_role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_role(%TeamRole{} = team_role) do
    Repo.delete(team_role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_role changes.

  ## Examples

      iex> change_team_role(team_role)
      %Ecto.Changeset{data: %TeamRole{}}

  """
  def change_team_role(
        %TeamRole{} = team_role,
        attrs \\ %{}
      ) do
    TeamRole.changeset(team_role, attrs)
  end
end
