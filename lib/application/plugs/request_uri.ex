defmodule RunaWeb.Plugs.RequestUri do
  @moduledoc """
  Plug to save the current request URI in the connection assigns.
  """
  use RunaWeb, :controller

  def call(%Plug.Conn{} = conn, _opts) do
    save_request_path(conn)
  end

  defp save_request_path(conn) do
    current_path = conn.request_path || "/"

    query_string = conn.query_string

    full_uri =
      if query_string == "",
        do: current_path,
        else: "#{current_path}?#{query_string}"

    assign(conn, :current_uri, full_uri)
  end
end
