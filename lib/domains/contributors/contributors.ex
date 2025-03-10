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
  def get(id) do
    query = from p in Contributor, where: p.id == ^id, preload: [:team, :user]

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
    |> broadcast(:contributor_created)
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
  def update(_, attrs \\ %{})

  def update(id, attrs) when is_number(id) do
    case get(id) do
      {:ok, data} -> __MODULE__.update(data, attrs)
      {:error, error} -> {:error, error}
    end
  end

  def update(%Contributor{} = contributor, attrs) do
    contributor
    |> Contributor.changeset(attrs)
    |> Repo.update()
    |> broadcast(:contributor_updated)
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
    |> broadcast(:contributor_deleted)
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

  def subscribe do
    PubSub.subscribe(Contributor.__schema__(:source))
  end

  defp broadcast({:ok, %Contributor{} = data}, event) do
    PubSub.broadcast(Contributor.__schema__(:source), {event, data})

    {:ok, data}
  end

  defp broadcast({:error, reason}, _event), do: {:error, reason}
end
