defmodule Runa.Projects do
  @moduledoc """
  The projects context.
  """

  use Runa, :context

  alias Runa.Languages.Language
  alias Runa.Projects.Project
  alias Runa.Teams.Team

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
  def index(opts \\ %{}) do
    Project
    |> preload([:keys, :languages, :team, :files, :base_language])
    |> paginate(opts, for: Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.
  """
  def get(id) do
    query =
      from(p in Project,
        where: p.id == ^id,
        preload: [:keys, :languages, :team, :files, :base_language]
      )

    case Repo.one(query) do
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
  def create(attrs \\ %{}) do
    %Project{}
    |> change(attrs)
    |> Repo.insert()
    |> case do
      {:ok, project} ->
        {:ok, Repo.preload(project, [:team, :base_language, :languages])}

      error ->
        error
    end
    |> broadcast(:project_created)
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """

  @spec update(Ecto.Schema.t(), map) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(%Project{} = project, attrs) do
    project
    |> Repo.preload([:team, :languages, :base_language])
    |> change(attrs)
    |> Repo.update()
    |> broadcast(:project_updated)
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete(project)
      {:ok, %Project{}}

      iex> delete(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Project{} = project) do
    Repo.delete(project)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change(project)
      %Ecto.Changeset{}

  """
  @spec change(Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def change(%Project{} = project, attrs \\ %{}) do
    project
    |> Repo.preload([:languages])
    |> Project.changeset(attrs)
    |> put_languages(attrs)
    |> put_base_language(attrs)
  end

  defp put_languages(changeset, attrs) do
    if Map.has_key?(attrs, "languages") do
      languages =
        Repo.all(from(l in Language, where: l.id in ^attrs["languages"]))

      Ecto.Changeset.put_assoc(changeset, :languages, languages)
    else
      changeset
    end
  end

  defp put_base_language(changeset, attrs) do
    if attrs["base_language_id"] && changed?(changeset, :base_language_id) do
      base_language =
        Repo.one(from(l in Language, where: l.id == ^attrs["base_language_id"]))

      %{changeset | data: %{changeset.data | base_language: base_language}}
    else
      changeset
    end
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

  def subscribe do
    PubSub.subscribe(Project.__schema__(:source))
  end

  def subscribe(%Team{} = data) do
    PubSub.subscribe("#{Project.__schema__(:source)}:#{data.id}")
  end

  defp broadcast({:ok, %Project{} = data}, event) do
    PubSub.broadcast(
      "#{Project.__schema__(:source)}:#{data.team.id}",
      {event, data}
    )

    {:ok, data}
  end

  defp broadcast({:error, reason}, _event), do: {:error, reason}
end
