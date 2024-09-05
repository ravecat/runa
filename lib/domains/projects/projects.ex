defmodule Runa.Projects do
  @moduledoc """
  The projects context.
  """

  use Runa, :context

  alias Runa.Projects.Project

  @doc """
  Returns the list of projects.

  ## Examples

      iex> index()
      [%Project{}, ...]

  """
  @spec index(keyword) ::
          {:ok, {[Project.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query = Project

    case page do
      %{} when map_size(page) > 0 ->
        Paginator.paginate(
          query,
          %{sort: sort, page: page, filter: filter},
          for: Project
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
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.
  """
  def get(id) do
    case Repo.get(Project, id) do
      nil -> {:error, %Ecto.NoResultsError{}}
      team -> {:ok, Repo.preload(team, :keys)}
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
      %Ecto.Changeset{data: %Project{}}

  """
  def change(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end
end
