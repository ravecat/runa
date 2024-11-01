defmodule Runa.Keys do
  @moduledoc """
  The Keys context.
  """

  use Runa, :context

  alias Runa.Keys.Key

  @doc """
  Returns the list of keys.

  ## Examples

      iex> index()
      [%Key{}, ...]

  """
  @spec index(keyword) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query = Key |> preload([:project])

    case page do
      %{} when map_size(page) > 0 ->
        Paginator.paginate(
          query,
          %{sort: sort, page: page, filter: filter},
          for: Key
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

      iex> delete_key(key)
      {:ok, %Key{}}

      iex> delete_key(key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_key(%Key{} = key) do
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
