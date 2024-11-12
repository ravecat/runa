defmodule Runa.Contributors do
  @moduledoc """
  The team role context.
  """

  use Runa, :context

  alias Runa.Contributors.Contributor

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
  Gets a single contributor.

  Returns {:ok, contributor} or {:error, %Ecto.NoResultsError{}} if not found.

  ## Examples

      iex> get(id)
      {:ok, %Contributor{}}

      iex> get(non_existing_id)
      {:error, %Ecto.NoResultsError{}}

  """
  def get(id) do
    query =
      from p in Contributor,
        where: p.id == ^id,
        preload: [:team, :user]

    case Repo.one(query) do
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
  def create(attrs \\ %{}) do
    %Contributor{}
    |> Contributor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contributor.

  ## Examples

      iex> update(contributor, %{field: new_value})
      {:ok, %Contributor{}}

      iex> update(contributor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Contributor{} = contributor, attrs) do
    contributor
    |> Contributor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contributor.

  ## Examples

      iex> delete(contributor)
      {:ok, %Contributor{}}

      iex> delete(contributor)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Contributor{} = contributor) do
    Repo.delete(contributor)
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
end
