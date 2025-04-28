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

  use RunaWeb, :controller
  use RunaWeb, :verified_routes

  require Logger

  alias Runa.Invitations
  alias RunaWeb.Plugs.Authentication

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
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
        create(conn, user)

      {:error, reason} ->
        conn |> put_flash(:error, reason) |> redirect(to: ~p"/")
    end
  end

  defp create(conn, user) do
    conn
    |> put_session(:user_id, user.id)
    |> process_invitation(user)
    |> configure_session(renew: true)
    |> redirect(to: ~p"/profile")
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  defp process_invitation(conn, user) do
    with invitation_token when is_binary(invitation_token) <-
           get_session(conn, :invitation_token),
         {:ok, invitation} <- Invitations.get_invitation(invitation_token),
         {:ok, _} <- Invitations.accept_invitation(user, invitation) do
      delete_session(conn, :invitation_token)
    else
      _ -> conn
    end
  end

  if Mix.env() == :dev do
    def quick_login(conn, %{"user_id" => user_id}) do
      case Runa.Accounts.get_by(id: user_id) do
        nil -> put_flash(conn, :error, "User not found")
        user -> create(conn, user)
      end
    end
  end
end
