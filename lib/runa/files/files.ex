defmodule Runa.Files do
  @moduledoc """
  The Files context.
  """

  use Runa, :context

  alias Runa.Files.File

  @doc """
  Returns the list of files.

  ## Examples

      iex> index()
      [%File{}, ...]

  """
  def index do
    Repo.all(File)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id), do: Repo.get!(File, id)

  @doc """
  Creates a file.

  ## Examples

      iex> create(%{field: value})
      {:ok, %File{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(map) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs \\ %{}) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} -> {:ok, Repo.preload(data, :project)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Creates a file from a LiveView upload entry.
  """

  @type meta() :: %{
          path: String.t(),
          project_id: String.t(),
          language_id: String.t()
        }
  @spec create(Phoenix.LiveView.UploadEntry.t(), meta(), [
          {String.t(), String.t()}
        ]) ::
          {:ok, any()} | {:error, any()}
  def create(entry, meta, data) do
    keys =
      Enum.map(data, fn {name, translation} ->
        %{
          name: name,
          translations: [
            %{translation: translation, language_id: meta.language_id}
          ]
        }
      end)

    %File{}
    |> File.changeset(%{
      filename: entry.client_name,
      project_id: meta.project_id,
      keys: keys
    })
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update(file, %{field: new_value})
      {:ok, %File{}}

      iex> update(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete(file)
      {:ok, %File{}}

      iex> delete(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%File{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change(file)
      %Ecto.Changeset{ %File{}}

  """
  def change(%File{} = file, attrs \\ %{}) do
    File.changeset(file, attrs)
  end
end
