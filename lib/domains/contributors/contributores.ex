defmodule Runa.Contributors do
  @moduledoc """
  The team role context.
  """

  use Runa, :context

  alias Runa.Contributors.Contributor

  @doc """
  Returns the list of contributors.

  ## Examples

      iex> get_contributors()
      [%Contributor{}, ...]

  """
  def get_contributors do
    Repo.all(Contributor)
  end

  @doc """
  Gets a single contributor.

  Raises `Ecto.NoResultsError` if the Team role does not exist.

  ## Examples

      iex> get_contributor!(123)
      %Contributor{}

      iex> get_contributor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contributor!(id), do: Repo.get!(Contributor, id)

  @doc """
  Creates a contributor.

  ## Examples

      iex> create_contributor(%{field: value})
      {:ok, %Contributor{}}

      iex> create_contributor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contributor(attrs \\ %{}) do
    %Contributor{}
    |> Contributor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contributor.

  ## Examples

      iex> update_contributor(contributor, %{field: new_value})
      {:ok, %Contributor{}}

      iex> update_contributor(contributor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_contributor(%Contributor{} = contributor, attrs) do
    contributor
    |> Contributor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a contributor.

  ## Examples

      iex> delete_contributor(contributor)
      {:ok, %Contributor{}}

      iex> delete_contributor(contributor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contributor(%Contributor{} = contributor) do
    Repo.delete(contributor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contributor changes.

  ## Examples

      iex> change_contributor(contributor)
      %Ecto.Changeset{data: %Contributor{}}

  """
  def change_contributor(
        %Contributor{} = contributor,
        attrs \\ %{}
      ) do
    Contributor.changeset(contributor, attrs)
  end
end
