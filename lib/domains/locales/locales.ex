defmodule Runa.Locales do
  @moduledoc """
  The Locales context.
  """

  use Runa, :context

  alias Runa.Locales.Locale

  @doc """
  Returns the list of locales.

  ## Examples

      iex> index()
      [%Locale{}, ...]

  """
  @spec index(keyword) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query = Locale |> preload([:project, :language])

    case page do
      %{} when map_size(page) > 0 ->
        Paginator.paginate(
          query,
          %{sort: sort, page: page, filter: filter},
          for: Locale
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
  Gets a single locale.

  Raises `Ecto.NoResultsError` if the Locale does not exist.

  ## Examples

      iex> get(123)
      %Locale{}

      iex> get(456)
      ** (Ecto.NoResultsError)

  """
  def get(id) do
    case Repo.get(Locale, id) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a locale.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Locale{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Locale{}
    |> Locale.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a locale.

  ## Examples

      iex> update(locale, %{field: new_value})
      {:ok, %Locale{}}

      iex> update(locale, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Locale{} = data, attrs) do
    data
    |> Locale.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a locale.

  ## Examples

      iex> delete(locale)
      {:ok, %Locale{}}

      iex> delete(locale)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Locale{} = data) do
    Repo.delete(data)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locale changes.

  ## Examples

      iex> change(locale)
      %Ecto.Changeset{data: %Locale{}}

  """
  def change(%Locale{} = data, attrs \\ %{}) do
    Locale.changeset(data, attrs)
  end
end
