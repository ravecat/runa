defmodule RunaWeb.Auth.Controller do
  @moduledoc """
  This controller handles authentication.

  It provides a `logout` action to log the user out and a `callback` action
  that is called by the Ueberauth library after the user has authenticated.

  The `callback` action will either create a new user or log in an existing user
  and then redirect the user to the home page.

  If the authentication fails, the `callback` action will redirect the user to the
  home page with an error message.
  """
  use RunaWeb, :controller
  use RunaWeb, :verified_routes

  require Logger

  plug Ueberauth

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    with {:ok, user} <- Runa.Auth.find_or_create(auth),
         {:ok, _team} <-
           Runa.Teams.create_team(%{
             title: "#{user.name}'s Team",
             owner_id: user.uid
           }) do
      conn
      |> put_flash(:info, "Successfully authenticated as #{user.name}.")
      |> put_session(:current_user, user)
      |> redirect(to: ~p"/profile")
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/")
    end
  end
end
