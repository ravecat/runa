defmodule RunaWeb.APICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a API connection.
  """

  use ExUnit.CaseTemplate

  import Runa.Factory

  using do
    quote do
      @moduledoc false

      @moduletag :api

      use ExUnit.Case

      import OpenApiSpex.TestAssertions

      alias RunaWeb.JSONAPI
    end
  end

  setup_all do
    {:ok, spec: RunaWeb.APISpec.spec()}
  end

  setup ctx do
    conn = ctx.conn |> put_x_api_key_header() |> put_json_api_headers()

    {:ok, conn: conn}
  end

  defp put_json_api_headers(conn) do
    conn
    |> Plug.Conn.put_req_header("accept", "application/vnd.api+json")
    |> case do
      %{method: _method} ->
        Plug.Conn.put_req_header(
          conn,
          "content-type",
          "application/vnd.api+json"
        )

      _ ->
        conn
    end
  end

  defp put_x_api_key_header(conn) do
    token = insert(:token, user: fn -> build(:user) end, access: :write)

    Plug.Conn.put_req_header(
      conn,
      RunaWeb.JSONAPI.Headers.api_key(),
      token.token
    )
  end
end
