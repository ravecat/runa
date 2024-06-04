defmodule RunaWeb.Plug.Authentication do
  @moduledoc """
  Plug for protecting routes that require authentication.
  """
  import Plug.Conn

  use RunaWeb, :controller

  def call(%Plug.Conn{} = conn, _default) do
    user = get_session(conn, :current_user)

    case user do
      nil ->
        conn
        |> put_flash(:error, "You can't access that page")
        |> redirect(to: ~p"/")
        |> halt()

      _ ->
        conn
    end
  end
end
