defmodule RunaWeb.FormattersTest do
  @moduledoc false

  use ExUnit.Case

  alias RunaWeb.Formatters

  @moduletag :formatters

  test "format_datetime_to_timestamp/1" do
    dt = DateTime.utc_now()

    assert Formatters.format_datetime_to_timestamp(dt) ==
             DateTime.to_unix(dt) |> Integer.to_string()
  end
end
