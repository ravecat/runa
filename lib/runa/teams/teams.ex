defmodule Runa.Teams do
  @moduledoc """
  The teams context.
  """

  use Runa, :context

  alias Runa.Contributors
  alias Runa.Contributors.Contributor
  alias Runa.Projects.Project
  alias Runa.Teams.Team

  @doc """
  Returns paginated list of teams.

  ## Examples
      iex> Teams.index(%Scope{})
      {:ok, {[%Team{}], %Flop.Meta{}}}

      iex> Teams.index(%Scope{}, page: -1)
      {:error, %Flop.Meta{}}
  """
  @spec index(Scope.t(), Paginator.opts()) ::
          {:ok, {[Team.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(%Scope{} = _scope, opts \\ %{}) do
    Team
    |> preload([:projects])
    |> paginate(opts, for: Team)
  end

  @doc """
  Gets a single team by id.

  Raises `Ecto.NoResultsError` if team does not exist.

  ## Examples
      iex> Teams.get(%Scope{}, 1)
      {:ok, %Team{}}

      iex> Teams.get(%Scope{}, 999)
      {:error, %Ecto.NoResultsError{}}
  """
  @spec get(Scope.t(), integer()) ::
          {:ok, Team.t()} | {:error, Ecto.NoResultsError}
  def get(%Scope{} = _scope, id) do
    from(p in Team, where: p.id == ^id, preload: [:projects])
    |> Repo.one()
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Returns team by attributes.

  ## Examples
      iex> Teams.get_by(name: "test")
      {:ok, %Team{}}

      iex> Teams.get_by(name: "unknown")
      {:error, %Ecto.NoResultsError{}}
  """
  @spec get_by(keyword()) :: {:ok, Team.t()} | {:error, Ecto.NoResultsError}
  def get_by(attrs \\ []) do
    Repo.get_by(Team, attrs)
  end

  @doc """
  Creates a team.

  It also creates contributor record for current user with `:owner` role.

  ## Examples
      iex> Teams.create(%Scope{}, %{name: "awesome team"})
      {:ok, %Team{}}

      iex> Teams.create(%Scope{}, %{})
      {:error, %Ecto.Changeset{}}
  """
  @spec create(Scope.t(), map(), keyword()) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def create(%Scope{} = scope, attrs, opts \\ []) do
    changeset_func = Keyword.get(opts, :with, &change/2)

    %Team{}
    |> changeset_func.(attrs)
    |> Repo.insert()
    |> case do
      {:ok, team} ->
        Contributors.create(scope, %{
          user_id: scope.current_user_id,
          team_id: team.id,
          role: :owner
        })

        team = Repo.preload(team, [:projects])

        broadcast(scope, %Events.TeamCreated{data: team})

        {:ok, team}

      other ->
        other
    end
  end

  @doc """
  Updates a team.

  ## Examples
      iex> Teams.update(%Scope{}, team, %{name: "new name"})
      {:ok, %Team{}}

      iex> Teams.update(%Scope{}, team, %{})
      {:error, %Ecto.Changeset{}}
  """
  @spec update(Scope.t(), Team.t(), map()) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def update(%Scope{} = scope, %Team{} = data, attrs) do
    data
    |> Team.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, team} ->
        broadcast(scope, %Events.TeamUpdated{data: team})
        {:ok, team}

      other ->
        other
    end
  end

  @doc """
  Deletes a team.

  ## Examples
      iex> Teams.delete(%Scope{}, team)
      {:ok, %Team{}}

      iex> Teams.delete(%Scope{}, team)
      {:error, %Ecto.Changeset{}}
  """
  @spec delete(Scope.t(), Team.t()) ::
          {:ok, Team.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Scope{} = scope, %Team{} = team) do
    Repo.delete(team)
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.TeamDeleted{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  def delete(%Scope{} = scope, id) do
    get(scope, id)
    |> case do
      {:ok, team} -> delete(scope, team)
      other -> other
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  Used for validation and data manipulation before persistence.

  ## Examples
      iex> Teams.change(%Team{})
      %Ecto.Changeset{data: %Team{}, valid?: true}
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
        id: p.id,
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
      project
      |> Map.from_struct()
      |> Map.drop([
        :__struct__,
        :__meta__,
        :files,
        :team,
        :base_language,
        :locales
      ])
      |> Map.put(:statistics, %{
        languages_count: data.languages_count,
        keys_count: data.keys_count,
        files_count: data.files_count,
        done: data.done
      })
    end)
  end

  @doc """
  Returns list of teams with user's role.
  """
  @spec get_user_teams_with_role(binary()) :: [{Team.t(), atom()}]
  def get_user_teams_with_role(user_id) do
    from(t in Team,
      join: c in Contributor,
      on: c.team_id == t.id,
      where: c.user_id == ^user_id,
      select: {t, c.role}
    )
    |> Repo.all()
  end

  @doc """
  Returns team by project id.
  """
  @spec get_team_by_project_id(binary()) ::
          {:ok, Team.t()} | {:error, %{__struct__: Ecto.NoResultsError}}
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

  @doc """
  Returns team owner.
  """
  @spec get_owner(Team.t() | integer()) :: Runa.Accounts.User.t() | nil
  def get_owner(%Team{id: id}), do: get_owner(id)

  def get_owner(team_id) when is_integer(team_id) do
    query =
      from c in Contributor,
        where: c.team_id == ^team_id and c.role == :owner,
        join: u in assoc(c, :user),
        select: u

    Repo.one(query)
  end

  @doc """
  Returns available contributor roles.
  """
  @spec get_roles() :: keyword()
  def get_roles, do: Contributor.roles()

  @doc """
  Returns team members.
  """
  @spec get_members(Team.t() | integer()) :: [Contributors.Contributor.t()]
  def get_members(%Team{id: id}), do: get_members(id)

  def get_members(team_id) do
    from(c in Contributor, where: c.team_id == ^team_id, preload: [:user])
    |> Repo.all()
  end

  @doc """
  Returns team member by id.
  """
  @spec get_member(Contributor.t() | integer()) ::
          Runa.Contributors.Contributor.t() | nil
  def get_member(%Contributor{id: id} = contributor) do
    case assoc_loaded?(contributor.user) do
      true -> contributor
      false -> get_member(id)
    end
  end

  def get_member(contributor_id) do
    from(c in Contributor, where: c.id == ^contributor_id, preload: [:user])
    |> Repo.one()
  end

  @spec subscribe(Scope.t()) :: :ok | {:error, term()}
  def subscribe(%Scope{} = scope) do
    PubSub.subscribe(topic(scope))
  end

  @spec broadcast(Scope.t(), term()) :: :ok | {:error, term()}
  defp broadcast(%Scope{} = scope, event) do
    PubSub.broadcast(topic(scope), event)
  end

  defp topic(scope),
    do: "#{Team.__schema__(:source)}:#{scope.current_user.id}"
end
