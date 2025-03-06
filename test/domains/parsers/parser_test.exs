defmodule Runa.ParserTest do
  use ExUnit.Case, async: true
  use Repatch.ExUnit

  alias Runa.Parser

  describe "process/2" do
    test "successfully parses a JSON file" do
      file_path = "test/fixtures/json/v1.json"

      entry = %Phoenix.LiveView.UploadEntry{client_name: "v1.json"}

      Repatch.patch(Runa.Parsers.JSON, :parse, [mode: :shared], fn path ->
        {:ok, path}
      end)

      {:ok, pid} = Parser.process(file_path, entry)

      Repatch.allow(self(), pid)

      assert_receive {:file_parsing_complete, %Phoenix.LiveView.UploadEntry{},
                      {:ok, ^file_path}}
    end
  end

  test "return an error for unknown extension" do
    file_path = "test/fixtures/json/v1.unknown"

    entry = %Phoenix.LiveView.UploadEntry{client_name: "v1.unknown"}

    Parser.process(self(), file_path, entry)

    assert_receive {:file_parsing_complete, %Phoenix.LiveView.UploadEntry{},
                    {:error, _}}
  end
end
