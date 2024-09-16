defmodule Runa.Languages do
  @moduledoc """
  The Languages context.
  """

  use Runa, :context

  alias Runa.Languages.Language

  @doc """
  Returns the list of languages.

  ## Examples

      iex> index()
      [%Language{}, ...]

  """
  @spec index(keyword) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})

    query = Language

    case page do
      %{} when map_size(page) > 0 ->
        Paginator.paginate(
          query,
          %{sort: sort, page: page, filter: filter},
          for: Language
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
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get(123)
      %Language{}

      iex> get(456)
      ** (Ecto.NoResultsError)

  """
  def get(id) do
    case Repo.get(Language, id) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a language.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Language{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a language.

  ## Examples

      iex> delete(language)
      {:ok, %Language{}}

      iex> delete(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change(language)
      %Ecto.Changeset{data: %Language{}}

  """
  def change(%Language{} = language, attrs \\ %{}) do
    Language.changeset(language, attrs)
  end
end
