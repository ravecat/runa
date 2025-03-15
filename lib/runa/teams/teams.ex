defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Contributors
  alias Runa.Contributors.Contributor
  alias Runa.Projects.Project
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
    query = from(p in Team, where: p.id == ^id, preload: [:projects])

    case Repo.one(query) do
      nil -> {:error, %{__struct__: Ecto.NoResultsError}}
      data -> {:ok, data}
    end
  end

  @doc """
  Returns a team by attributes.

  ## Examples

      iex> get_by(user_id: 1)
      {:ok, %Team{}}

      iex> get_by(user_id: 1)
      {:error, %Ecto.NoResultsError{}}

  """
  def get_by(attrs \\ []) do
    Repo.get_by(Team, attrs)
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
    |> broadcast(:team_created)
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
    |> broadcast(:team_created)
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
    |> broadcast(:team_updated)
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
    |> broadcast(:team_deleted)
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

  def get_projects_with_statistics(team_id) do
    from(p in Project,
      where: p.team_id == ^team_id,
      preload: [:languages],
      left_join: l in assoc(p, :languages),
      left_join: f in assoc(p, :files),
      left_join: k in assoc(f, :keys),
      left_join: t in assoc(k, :translations),
      group_by: p.id,
      select: %{
        project: p,
        languages_count: count(l.id, :distinct),
        keys_count: count(k.id, :distinct),
        files_count: count(f.id, :distinct),
        done:
          fragment(
            """
            CASE
              WHEN COUNT(DISTINCT ?) * COUNT(DISTINCT ?) = 0 THEN 0
              ELSE ROUND((SUM(CASE WHEN ? IS NOT NULL THEN 1 ELSE 0 END)::float /
              (COUNT(DISTINCT ?) * COUNT(DISTINCT ?)))::numeric * 100, 1)
            END
            """,
            k.id,
            l.id,
            t.id,
            k.id,
            l.id
          )
      }
    )
    |> Repo.all()
    |> Enum.map(fn %{project: project} = data ->
      Map.merge(project, %{
        statistics: %{
          languages_count: data.languages_count,
          keys_count: data.keys_count,
          files_count: data.files_count,
          done: data.done
        }
      })
    end)
  end

  @spec get_user_teams_with_role(binary()) :: [{Ecto.Schema.t(), atom()}]
  def get_user_teams_with_role(user_id) do
    from(t in Team,
      join: c in Contributor,
      on: c.team_id == t.id,
      where: c.user_id == ^user_id,
      select: {t, c.role}
    )
    |> Repo.all()
  end

  @spec get_team_by_project_id(binary()) ::
          {:ok, Ecto.Schema.t()} | {:error, %{__struct__: Ecto.NoResultsError}}
  def get_team_by_project_id(project_id) do
    query =
      from t in Team,
        join: p in assoc(t, :projects),
        where: p.id == ^project_id,
        select: t

    case Repo.one(query) do
      nil -> {:error, %{__struct__: Ecto.NoResultsError}}
      data -> {:ok, data}
    end
  end

  @spec get_owner(Ecto.Schema.t() | integer()) :: Ecto.Schema.t() | nil
  def get_owner(%Team{id: id}), do: get_owner(id)

  def get_owner(team_id) when is_integer(team_id) do
    query =
      from c in Contributor,
        where: c.team_id == ^team_id and c.role == :owner,
        join: u in assoc(c, :user),
        select: u

    Repo.one(query)
  end

  @spec get_roles() :: keyword()
  def get_roles, do: Contributor.roles()

  @spec get_members(Ecto.Schema.t() | integer()) :: [Ecto.Schema.t()]
  def get_members(%Team{id: id}), do: get_members(id)

  def get_members(team_id) do
    query =
      from c in Contributor, where: c.team_id == ^team_id, preload: [:user]

    Repo.all(query)
  end

  @spec get_member(Ecto.Schema.t() | integer()) :: Ecto.Schema.t() | nil
  def get_member(%Contributor{id: id} = contributor) do
    case assoc_loaded?(contributor.user) do
      true -> contributor
      false -> get_member(id)
    end
  end

  def get_member(contributor_id) do
    query =
      from(c in Contributor, where: c.id == ^contributor_id, preload: [:user])

    Repo.one(query)
  end

  def subscribe do
    PubSub.subscribe(Team.__schema__(:source))
  end

  defp broadcast({:ok, %Team{} = data}, event) do
    PubSub.broadcast(Team.__schema__(:source), {event, data})

    {:ok, data}
  end

  defp broadcast({:error, reason}, _event), do: {:error, reason}
end
