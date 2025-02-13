defmodule Runa.Storage.S3 do
  @moduledoc """
  Adapter for storing files in Amazon S3.
  Implements the `Runa.Storage` behaviour.
  Configuration is read from the application environment under the `:runa, Runa.Storage.S3` key.
  """

  @behaviour Runa.Storage

  alias ExAws.S3

  @impl true
  def upload(file, bucket, opts \\ []) do
    with {:ok, bucket} <- find_or_create_bucket(bucket),
         stream <- S3.Upload.stream_file(file),
         op <- S3.upload(stream, bucket, "/", opts),
         {:ok, response} <- ExAws.request(op) do
      {:ok, response}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def index(_bucket, _opts \\ []) do
    :not_implemented
  end

  @impl true
  def download(_bucket, _path, _opts \\ []) do
    :not_implemented
  end

  @impl true
  def delete(_bucket, _path, _opts \\ []) do
    :not_implemented
  end

  defp find_or_create_bucket(bucket) do
    region = Application.get_env(:runa, Runa.Storage.S3)[:region]

    with {:ok, _} <- bucket_exists?(bucket),
         {:ok, _} <- create_bucket(bucket, region) do
      {:ok, bucket}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp bucket_exists?(bucket) do
    ExAws.S3.head_bucket(bucket)
    |> ExAws.request()
    |> case do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        {:error, error}
    end
  end

  defp create_bucket(bucket, region) do
    ExAws.S3.put_bucket(bucket, region)
    |> ExAws.request()
    |> case do
      {:ok, response} ->
        {:ok, response}

      {:error, error} ->
        {:error, error}
    end
  end
end
