defmodule Runa.Languages do
  @moduledoc """
  The Languages context.
  """

  use Runa, :context

  alias Runa.Languages.Language

  @doc """
  Returns the list of languages with pagination metadata.

  ## Examples

      iex> index()
      {:ok, {[%Language{}, ...], %Flop.Meta{}}}

      iex> index(%{page: 2, page_size: 10})
      {:ok, {[%Language{}, ...], %Flop.Meta{}}}
  """
  @spec index(Paginator.params()) ::
          {:ok, {[Ecto.Schema.t()], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def index(opts \\ %{}) do
    Language
    |> paginate(opts, for: Language)
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
  Get a language by attributes.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples
      iex> get_by([name: "English"])
      %Language{}
  """

  def get_by(attrs \\ []) do
    Repo.get_by(Language, attrs)
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
