defmodule RunaWeb.JSONAPICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection and
  JSON API responses.
  """

  defmacro __using__(_) do
    quote do
      setup %{conn: conn} do
        conn =
          conn
          |> put_req_header("accept", "application/vnd.api+json")
          |> case do
            %{method: method} ->
              put_req_header(conn, "content-type", "application/vnd.api+json")

            _ ->
              conn
          end

        {:ok, conn: conn}
      end
    end
  end
end
