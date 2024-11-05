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
  def index(opts \\ %{}) do
    Project
    |> preload([:keys, :languages, :team, :files])
    |> paginate(opts, for: Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.
  """
  def get(id) do
    query =
      from p in Project,
        where: p.id == ^id,
        preload: [:keys, :languages, :team]

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
    |> Project.changeset(attrs)
    |> Repo.insert()
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
    |> Project.changeset(attrs)
    |> Repo.update()
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
  def change(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
