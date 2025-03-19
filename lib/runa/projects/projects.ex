defmodule Runa.Projects do
  @moduledoc """
  The projects context.
  """

  use Runa, :context

  alias Runa.Projects.Project

  @doc """
  Returns the list of projects with pagination metadata.

  ## Examples

      iex> index()
      {:ok, {[%Project{}, ...], %Flop.Meta{}}}

      iex> index(%{page: 2, page_size: 10})
      {:ok, {[%Project{}, ...], %Flop.Meta{}}}
  """
  @spec index(Paginator.params()) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(%Scope{} = _scope, opts \\ %{}) do
    Project
    |> preload([:languages, :team, :files, :base_language])
    |> paginate(opts, for: Project)
  end

  @doc """
  Gets a single project.

  ## Examples
     iex> get(1)
      {:ok, %Project{}}


      iex> get(99)
      {:error, %Ecto.NoResultsError{}}
  """
  def get(%Scope{} = _scope, id) do
    from(p in Project,
      where: p.id == ^id,
      preload: [:languages, :team, :files, :base_language]
    )
    |> Repo.one()
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Project{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(map, keyword()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(%Scope{} = scope, attrs, opts \\ []) do
    changeset_func = Keyword.get(opts, :with, &change/2)

    %Project{}
    |> changeset_func.(attrs)
    |> Repo.insert()
    |> case do
      {:ok, project} ->
        project = Repo.preload(project, [:team, :base_language, :languages])

        broadcast(scope, %Events.ProjectCreated{data: project})

        {:ok, project}

      other ->
        other
    end
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """

  @spec update(Ecto.Schema.t(), map, keyword()) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(%Scope{} = scope, %Project{} = project, attrs, opts \\ []) do
    changeset_func = Keyword.get(opts, :with, &change/2)

    project
    |> changeset_func.(attrs)
    |> Repo.update()
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.ProjectUpdated{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete(project)
      {:ok, %Project{}}

      iex> delete(project)
      {:error, %Ecto.Changeset{}}

  """
  @spec change(Ecto.Schema.t() | integer()) :: Ecto.Schema.t()
  def delete(%Scope{} = scope, %Project{} = project) do
    Repo.delete(project)
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.ProjectDeleted{data: data})

        {:ok, data}

      other ->
        other
    end
  end

  def delete(%Scope{} = scope, id) do
    get(scope, id)
    |> case do
      {:ok, project} -> delete(scope, project)
      other -> other
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change(project)
      %Ecto.Changeset{}

  """
  @spec change(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def change(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  @doc """
  Returns a project duplicate.

  ## Examples
  iex> duplicate(project)
  {:ok, %Project{}}
  """

  def duplicate(%Project{} = project, attrs \\ %{}) do
    Repo.duplicate(project, attrs)
  end

  def subscribe(%Scope{} = scope) do
    PubSub.subscribe(topic(scope))
  end

  defp broadcast(%Scope{} = scope, event) do
    PubSub.broadcast(topic(scope), event)
  end

  defp topic(scope),
    do: "#{Project.__schema__(:source)}:#{scope.current_user.id}"
end
