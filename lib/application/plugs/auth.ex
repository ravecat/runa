defmodule RunaWeb.AuthPlug do
  @moduledoc """
  This plug is used to protect routes that require authentication.
  If the user is not authenticated, they will be redirected to the home page.
  """
  import Plug.Conn

  use RunaWeb, :controller

  def init(default), do: default

  def call(%Plug.Conn{} = conn, :authenticate) do
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

  def call(%Plug.Conn{} = conn, :identify) do
    user = get_session(conn, :current_user)

    assign(conn, :current_user, user)
  end
end
