defmodule Runa.Storage do
  @moduledoc """
  Defines the behaviour for storage adapters.
  Adapters should implement the functions defined in this behaviour.
  """

  @callback upload(binary(), keyword()) ::
              {:ok, String.t()} | {:error, term}
  @callback index(binary(), keyword()) ::
              {:ok, list(binary())} | {:error, term}
  @callback download(binary(), keyword()) :: {:ok, binary()} | {:error, term}
  @callback delete(binary(), keyword()) :: :ok | {:error, term}

  @optional_callbacks index: 2

  @doc """
  Uploads a file using the configured adapter.
  """
  def upload(file, adapter, opts \\ []) do
    case adapter do
      :s3 -> Runa.Storage.S3.upload(file, opts)
      other -> {:error, "Unknown storage adapter: #{other}"}
    end
  end
end
