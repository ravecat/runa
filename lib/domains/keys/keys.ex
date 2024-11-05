defmodule Runa.Keys do
  @moduledoc """
  The Keys context.
  """

  use Runa, :context

  alias Runa.Keys.Key

  @doc """
  Returns the list of keys with pagination metadata.

  ## Examples

      iex> index()
      {:ok, {[%Key{}, ...], %Flop.Meta{}}}

      iex> index(%{page: 2, page_size: 10})
      {:ok, {[%Key{}, ...], %Flop.Meta{}}}
  """
  @spec index(Paginator.params()) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ %{}) do
    Key
    |> preload([:project])
    |> paginate(opts, for: Key)
  end

  @doc """
  Gets a single key.

  Raises `Ecto.NoResultsError` if the Key does not exist.

  ## Examples

      iex> get(123)
      {:ok, %Key{}}

      iex> get(456)
      {:error, %Ecto.NoResultsError{}}

  """
  def get(id) do
    query =
      from p in Key,
        where: p.id == ^id,
        preload: [:project]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a key.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Key{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Key{}
    |> Key.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} -> {:ok, Repo.preload(data, :project)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a key.

  ## Examples

      iex> update(key, %{field: new_value})
      {:ok, %Key{}}

      iex> update(key, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(Ecto.Schema.t(), map) ::
          {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def update(%Key{} = key, attrs) do
    key
    |> Key.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a key.

  ## Examples

      iex> delete(key)
      {:ok, %Key{}}

      iex> delete(key)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Key{} = key) do
    Repo.delete(key)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking key changes.

  ## Examples

      iex> change_key(key)
      %Ecto.Changeset{data: %Key{}}

  """
  def change_key(%Key{} = key, attrs \\ %{}) do
    Key.changeset(key, attrs)
  end
end
