defmodule Runa.Files do
  @moduledoc """
  The Files context.
  """

  use Runa, :context

  alias Runa.Files.File
  alias Runa.Keys.Key

  @doc """
  Returns the list of files.

  ## Examples

      iex> get_files()
      [%File{}, ...]

  """
  def get_files do
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

  @type file_meta() :: %{project_id: String.t(), path: String.t()}
  @spec create(Phoenix.LiveView.UploadEntry.t(), file_meta(), [
          {String.t(), String.t()}
        ]) ::
          {:ok, any()} | {:error, any()} | Ecto.Multi.failure()
  def create(entry, meta, data) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :file,
      File.changeset(%File{}, %{
        filename: entry.client_name,
        project_id: meta.project_id
      })
    )
    |> Ecto.Multi.insert_all(
      :keys,
      Key,
      fn %{file: file} ->
        now = DateTime.truncate(DateTime.utc_now(), :second)

        Enum.map(
          data,
          &%{
            file_id: file.id,
            name: elem(&1, 0),
            inserted_at: now,
            updated_at: now
          }
        )
      end,
      returning: true
    )
    |> Repo.transaction()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%File{} = file) do
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
