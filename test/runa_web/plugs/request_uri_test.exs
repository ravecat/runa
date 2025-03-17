defmodule RunaWeb.Plugs.RequestUriTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias RunaWeb.Plugs.RequestUri

  describe "save request uri plug" do
    test "assigns current uri without query parameters", ctx do
      conn =
        ctx.conn
        |> Map.put(:request_path, "/some/path")
        |> Map.put(:query_string, "")

      result = RequestUri.call(conn, [])

      assert result.assigns[:current_uri] == "/some/path"
    end

    test "assigns current uri with query parameters", ctx do
      conn =
        ctx.conn
        |> Map.put(:request_path, "/some/path")
        |> Map.put(:query_string, "param1=value1&param2=value2")

      result = RequestUri.call(conn, [])

      assert result.assigns[:current_uri] ==
               "/some/path?param1=value1&param2=value2"
    end
  end
end
