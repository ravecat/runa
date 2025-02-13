defmodule Runa.Storage do
  @moduledoc """
  Defines the behaviour for storage adapters.
  Adapters should implement the functions defined in this behaviour.
  """

  @callback upload(binary(), String.t(), keyword()) ::
              {:ok, String.t()} | {:error, term}
  @callback index(String.t(), keyword()) ::
              {:ok, list(String.t())} | {:error, term}
  @callback download(String.t(), keyword()) :: {:ok, binary()} | {:error, term}
  @callback delete(String.t(), keyword()) :: :ok | {:error, term}

  @optional_callbacks index: 2
end
