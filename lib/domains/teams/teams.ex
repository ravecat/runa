defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  alias Runa.Repo
  alias Runa.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> get_teams()
      [%Team{}, ...]

  """
  def get_teams do
    Repo.all(Team) |> Repo.preload(:projects)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team(1)
      {:ok, %Team{}}

      iex> get_team(999)
      {:error, %Ecto.NoResultsError{}}

  """
  def get_team(id) do
    case Repo.get(Team, id) do
      nil ->
        {:error, %Ecto.NoResultsError{}}

      team ->
        team = Repo.preload(team, :projects)
        {:ok, team}
    end
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end
end
