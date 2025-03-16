defmodule Runa.Contributors do
  @moduledoc """
  The team role context.
  """

  use Runa, :context

  alias Runa.Contributors.Contributor
  alias Runa.Accounts.User

  @doc """
  Returns the list of contributors.

  ## Examples

      iex> index()
      [%Contributor{}, ...]

  """
  def index do
    Repo.all(Contributor)
  end

  @doc """
  Returns a contributor by attributes.

  ## Examples

      iex> get_by(user_id: 1, team_id: 1)
      {:ok, %Contributor{}}

      iex> get_by(user_id: 1)
      {:error, %Ecto.NoResultsError{}}

  """
  def get_by(attrs \\ []) do
    Repo.get_by(Contributor, attrs)
  end

  @doc """
  Gets a single contributor.

  Returns {:ok, contributor} or {:error, %Ecto.NoResultsError{}} if not found.

  ## Examples

      iex> get(id)
      {:ok, %Contributor{}}

      iex> get(non_existing_id)
      {:error, %Ecto.NoResultsError{}}

  """
  def get(%Scope{} = _scope, id) do
    from(p in Contributor, where: p.id == ^id, preload: [:team, :user])
    |> Repo.one()
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a contributor.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Contributor{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(%Scope{} = scope, attrs \\ %{}) do
    %Contributor{}
    |> Contributor.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.ContributorCreated{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  @doc """
  Updates a contributor.

  ## Examples

      iex> update(contributor, %{field: new_value})
      {:ok, %Contributor{}}

      iex> update(contributor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(Ecto.Schema.t() | binary(), map()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(_, _, attrs \\ %{})

  def update(%Scope{} = scope, %Contributor{} = contributor, attrs) do
    contributor
    |> Contributor.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.ContributorUpdated{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  def update(%Scope{} = scope, id, attrs) do
    case get(scope, id) do
      {:ok, data} -> __MODULE__.update(scope, data, attrs)
      {:error, error} -> {:error, error}
    end
  end

  @spec get_role(Ecto.Schema.t() | binary(), Ecto.Schema.t() | binary()) ::
          Ecto.Schema.t() | nil
  def get_role(%Team{} = team, %User{} = user) do
    get_role(user.id, team.id)
  end

  def get_role(user_id, team_id) do
    query =
      from c in Contributor,
        where: c.team_id == ^team_id and c.user_id == ^user_id,
        select: c.role

    Repo.one(query)
  end

  @doc """
  Deletes a contributor.

  ## Examples

      iex> delete(contributor)
      {:ok, %Contributor{}}

      iex> delete(contributor)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Scope{} = scope, %Contributor{} = contributor) do
    Repo.delete(contributor)
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.ContributorDeleted{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contributor changes.

  ## Examples

      iex> change(contributor)
      %Ecto.Changeset{data: %Contributor{}}

  """
  def change(%Contributor{} = contributor, attrs \\ %{}) do
    Contributor.changeset(contributor, attrs)
  end

  def subscribe(%Scope{} = scope) do
    PubSub.subscribe(topic(scope))
  end

  defp broadcast(%Scope{} = scope, event) do
    PubSub.broadcast(topic(scope), event)
  end

  defp topic(scope),
    do: "#{Contributor.__schema__(:source)}:#{scope.current_user.id}"
end
