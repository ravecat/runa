defmodule RunaWeb.Adapters.DateTimeTest do
  @moduledoc false

  use ExUnit.Case

  import RunaWeb.Adapters.DateTime

  @moduletag :formatters

  test "format_datetime_to_timestamp/1" do
    dt = DateTime.utc_now()

    assert dt_to_timestamp(dt) == DateTime.to_unix(dt) |> Integer.to_string()
  end
end
