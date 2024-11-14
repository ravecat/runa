defmodule RunaWeb.SessionController do
  @moduledoc """
  This controller handles sessions.

  It provides a `delete` action to log the user out and a `callback` action
  that is called by the Ueberauth library after the user has authenticated.

  The `callback` action will either create a new user or log in an existing user
  and then redirect the user to the home page.

  If the authentication fails, the `callback` action will redirect the user to the
  home page with an error message.
  """
  alias RunaWeb.Plugs.Authentication
  use RunaWeb, :controller
  use RunaWeb, :verified_routes

  require Logger

  plug Ueberauth

  def request(conn, _params) do
    conn
  end

  def callback(
        %{assigns: %{ueberauth_failure: _fails}} = conn,
        _params
      ) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(
        %{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn,
        _params
      ) do
    case Authentication.authenticate_by_auth_data(auth) do
      {:ok, user} ->
        conn
        |> login(user)
        |> redirect(to: ~p"/profile")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/")
    end
  end

  defp login(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end
end
