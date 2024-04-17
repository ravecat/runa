defmodule Runa.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Runa.Repo

  alias Runa.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> get_teams()
      [%Team{}, ...]

  """
  def get_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

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

  @doc """
  Returns the list of teams for a given fields values.
  """
  def get_teams_by(clauses) when is_list(clauses) do
    query =
      Enum.reduce(clauses, from(t in Team), fn {field, value}, acc ->
        from t in acc, where: field(t, ^field) == ^value
      end)

    Repo.all(query)
  end

  @doc """
  Ensures a team exists for a fields values.
  """
  def ensure_team(clauses, defaults) when is_list(clauses) and is_map(defaults) do
    case get_teams_by(clauses) do
      [] ->
        case create_team(defaults) do
          {:ok, team} -> {:ok, [team]}
          {:error, changeset} -> {:error, changeset}
        end

      teams ->
        {:ok, teams}
    end
  end
end
