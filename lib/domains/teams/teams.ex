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
      |> preload(:projects)

    case page do
      %{} when map_size(page) > 0 ->
        {order_direction, order_by} = Enum.unzip(sort)

        opts = %{
          order_by: order_by,
          order_direction: order_direction,
          filters: filter
        }

        paginate(%{
          query: query,
          page: page,
          opts: opts
        })

      _ ->
        index(%{query: query, sort: sort, filter: filter})
    end
  end

  def index(%{query: query, sort: sort, filter: filter}) do
    query
    |> where(^filter)
    |> order_by(^sort)
    |> Repo.all()
  end

  defp paginate(%{
         page: %{"number" => number, "size" => size},
         query: query,
         opts: opts
       }) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        page: number,
        page_size: size
      }),
      for: Team
    )
  end

  defp paginate(%{
         page: %{"offset" => offset, "limit" => limit},
         query: query,
         opts: opts
       }) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        offset: offset,
        limit: limit
      }),
      for: Team
    )
  end

  defp paginate(%{
         page: %{"after" => after_cursor, "size" => size},
         query: query,
         opts: opts
       }) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        after: after_cursor,
        first: size
      }),
      for: Team
    )
  end

  defp paginate(%{
         page: %{"before" => before_cursor, "size" => size},
         query: query,
         opts: opts
       }) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        before: before_cursor,
        last: size
      }),
      for: Team
    )
  end

  defp paginate(%{
         page: %{"size" => size},
         query: query,
         opts: opts
       }) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        first: size
      }),
      for: Team
    )
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
