defmodule Runa.Parsers.JSON do
  @moduledoc """
  JSON parser implementation using Flow and Jaxon.

  Parses JSON files using a streaming approach with Jaxon and processes
  them concurrently using Flow.  Supports nested objects and uses
  dot notation for nested keys.

  The parse function accepts a file path and returns a list of
  key-value pairs.
  """
  @behaviour Runa.Parser

  @impl true
  def parse(path) do
    path
    |> File.stream!()
    |> Jaxon.Stream.from_enumerable()
    |> Stream.transform([], &process/2)
    |> Enum.to_list()
    |> then(&{:ok, &1})
  end

  defp process([{:string, key}, :colon, {:string, value}, :comma], keys) do
    full_key = build_key(keys, key)
    {[{full_key, value}], keys}
  end

  defp process([{:string, key}, :colon, {:string, value}], keys) do
    full_key = build_key(keys, key)
    {[{full_key, value}], keys}
  end

  defp process([{:string, key}, :colon, :start_object], keys) do
    {[], [key | keys]}
  end

  defp process([:end_object], [_key | tail]) do
    {[], tail}
  end

  defp process([:end_object, :comma], [_key | tail]) do
    {[], tail}
  end

  defp process(_event, keys) do
    {[], keys}
  end

  defp build_key(keys, key) do
    Enum.join(Enum.reverse([key | keys]), ".")
  end
end
