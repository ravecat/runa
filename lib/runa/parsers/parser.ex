defmodule Runa.Parser do
  @moduledoc """
  Defines the behaviour for parsers.

  Implementations should implement the `parse/1` callback
  to parse the given input string and return the parsed result.
  """
  alias Runa.Parsers.JSON

  @callback parse(String.t()) ::
              {:ok, [{String.t(), String.t()}]} | {:error, term()}

  @spec process(pid(), String.t(), Phoenix.LiveView.UploadEntry.t()) ::
          {:ok, pid()}
  def process(pid \\ self(), path, entry) do
    Task.start_link(fn ->
      with {:ok, parser} <- select(entry),
           {:ok, result} <- parser.parse(path) do
        send(pid, {:file_parsing_complete, entry, {:ok, result}})
      else
        {:error, reason} ->
          send(pid, {:file_parsing_complete, entry, {:error, reason}})
      end
    end)
  end

  defp select(%{client_name: client_name}) do
    case Path.extname(client_name) do
      ".json" -> {:ok, JSON}
      ext -> {:error, "Unsupported file extension: #{ext}"}
    end
  end
end
