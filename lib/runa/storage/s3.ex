defmodule Runa.Storage.S3 do
  @moduledoc """
  Adapter for storing files in Amazon S3.
  Implements the `Runa.Storage` behaviour.
  Configuration is read from the application environment under the `:runa, Runa.Storage.S3` key.
  """

  @behaviour Runa.Storage

  alias ExAws.S3

  @impl true
  def upload(path, opts \\ []) do
    bucket =
      Keyword.get(
        opts,
        :bucket,
        Application.get_env(:runa, Runa.Storage.S3, :bucket)
      )

    with {:ok, bucket} <- find_or_create_bucket(bucket),
         {:ok, response} <-
           S3.Upload.stream_file(path)
           |> S3.upload(bucket, "/", opts)
           |> ExAws.request() do
      {:ok, response}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @impl true
  def index(_path, _opts \\ []) do
    :not_implemented
  end

  @impl true
  def download(_path, _opts \\ []) do
    :not_implemented
  end

  @impl true
  def delete(_path, _opts \\ []) do
    :not_implemented
  end

  defp find_or_create_bucket(bucket) do
    region = Application.get_env(:runa, Runa.Storage.S3)[:region]

    with {:ok, _} <- bucket_exists?(bucket),
         {:ok, _} <- create_bucket(bucket, region) do
      {:ok, bucket}
    else
      {:error, error} -> {:error, error}
    end
  end

  defp bucket_exists?(bucket) do
    S3.head_bucket(bucket)
    |> ExAws.request()
    |> case do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end

  defp create_bucket(bucket, region) do
    S3.put_bucket(bucket, region)
    |> ExAws.request()
    |> case do
      {:ok, response} -> {:ok, response}
      {:error, error} -> {:error, error}
    end
  end
end
