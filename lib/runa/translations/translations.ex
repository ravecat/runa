defmodule Runa.Translations do
  @moduledoc """
  The Translations context.
  """

  use Runa, :context

  alias Runa.Translations.Translation

  @doc """
  Returns the list of translations with pagination.

  ## Examples

      iex> index()
      {:ok, {[ %Translation{}, ...], %Flop.Meta{...}}}

      iex> index(page: 1, page_size: 2)
      {:ok, {[ %Translation{}, ...], %Flop.Meta{...}}}
  """
  @spec index(Ecto.Queryable.t(), Paginator.params()) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(query \\ Translation, opts \\ %{}) do
    paginate(query, opts, for: Translation)
  end

  @doc """
  Gets a single translation.

  Raises `Ecto.NoResultsError` if the Translation does not exist.

  ## Examples

      iex> get(123)
      %Translation{}

      iex> get(456)
      ** (Ecto.NoResultsError)

  """
  def get(id) do
    query =
      from(t in Translation, where: t.id == ^id, preload: [:key, :language])

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Creates a translation.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Translation{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %Translation{}
    |> Translation.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} -> {:ok, Repo.preload(data, [:key, :language])}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Updates a translation.

  ## Examples

      iex> update(translation, %{field: new_value})
      {:ok, %Translation{}}

      iex> update(translation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Translation{} = translation, attrs) do
    translation
    |> Translation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a translation.

  ## Examples

      iex> delete(translation)
      {:ok, %Translation{}}

      iex> delete(translation)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Translation{} = translation) do
    Repo.delete(translation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking translation changes.

  ## Examples

      iex> change(translation)
      %Ecto.Changeset{data: %Translation{}}

  """
  def change(%Translation{} = translation, attrs \\ %{}) do
    Translation.changeset(translation, attrs)
  end
end
