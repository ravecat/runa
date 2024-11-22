defmodule RunaWeb.JSONAPICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection and
  JSON API responses.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias RunaWeb.JSONAPI
    end
  end

  setup %{conn: conn} do
    conn =
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

    {:ok, conn: conn}
  end
end
