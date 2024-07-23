defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  use Runa, :context

  alias Runa.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> get_teams()
      [%Team{}, ...]

  """
  def get_teams(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query =
      Team
      |> where(^filter)
      |> order_by(^sort)
      |> preload(:projects)

    cond do
      is_map_key(page, "number") or is_map_key(page, "size") ->
        Repo.paginate(query, page: page["number"], page_size: page["size"])

      true ->
        Repo.all(query)
    end
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
        {:ok, Repo.preload(team, projects: [:keys])}
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
