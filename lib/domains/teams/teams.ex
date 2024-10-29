defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  use Runa, :context

  alias Runa.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples
      iex> index()
      [%Team{}, ...]
  """
  @spec index(keyword) ::
          {:ok, {[Team.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query = Team |> preload([:projects])

    case page do
      %{} when map_size(page) > 0 ->
        Paginator.paginate(
          query,
          %{sort: sort, page: page, filter: filter},
          for: Team
        )

      _ ->
        data =
          query
          |> where(^filter)
          |> order_by(^sort)
          |> Repo.all()

        {:ok, {data, %{}}}
    end
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
    case Repo.get(Team, id) do
      nil ->
        {:error, %Ecto.NoResultsError{}}

      data ->
        {:ok, data}
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
