defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Contributors
  alias Runa.Contributors.Contributor
  alias Runa.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples
      iex> index()
      [%Team{}, ...]
  """
  @spec index(Paginator.params()) ::
          {:ok, {[Team.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ %{}) do
    Team
    |> preload([:projects])
    |> paginate(opts, for: Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get(1)
      {:ok, %Team{}}

      iex> get(999)
      {:error, %Ecto.NoResultsError{}}

  """
  def get(id) do
    query =
      from p in Team,
        where: p.id == ^id,
        preload: [:projects]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Team{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def create(attrs, %User{} = user) do
    Multi.new()
    |> Multi.insert(:team, change(%Team{}, attrs))
    |> Multi.insert(
      :contributor,
      &Contributors.change(%Contributor{}, %{
        user_id: user.id,
        team_id: &1.team.id,
        role: :owner
      })
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{team: team}} -> {:ok, team}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Team{} = data, attrs) do
    data
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete(team)
      {:ok, %Team{}}

      iex> delete(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Team{} = data) do
    Repo.delete(data)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change(%Team{} = data, attrs \\ %{}) do
    Team.changeset(data, attrs)
  end
end
