defmodule RunaWeb.Plugs.APIKeyVerification do
  @moduledoc """
  Plug for API key verification.

  Check if API key is present and access rights corresponds to requsted method
  """

  use RunaWeb, :controller

  alias Runa.Tokens
  alias RunaWeb.ErrorJSON

  def call(conn, _opts) do
    header = RunaWeb.JSONAPI.Headers.api_key()

    conn
    |> get_req_header(header)
    |> validate(conn)
  end

  defp validate([], conn),
    do:
      conn
      |> put_status(401)
      |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
      |> render(:"401")
      |> halt()

  defp validate([api_key], conn) do
    case Tokens.get_by_token(api_key) do
      {:ok, token} ->
        check_rights(conn, token)

      {:error, _} ->
        conn
        |> put_status(401)
        |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
        |> render(:"401")
        |> halt()
    end
  end

  defp check_rights(conn, %{access: :write}), do: conn

  defp check_rights(conn, %{access: :read}) when conn.method in ~w(GET HEAD),
    do: conn

  defp check_rights(conn, _token) do
    conn
    |> put_status(403)
    |> put_view(json: ErrorJSON, jsonapi: ErrorJSON)
    |> render(:"403")
    |> halt()
  end
end
