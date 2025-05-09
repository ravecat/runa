defmodule RunaWeb.InvitationController do
  use RunaWeb, :controller
  use RunaWeb, :verified_routes

  alias Runa.Teams.Invitations

  def accept(conn, %{"token" => token}) do
    with {:ok, invitation} <- Invitations.get_invitation(token),
         user <- conn.assigns[:current_user],
         invitee_email <- invitation.email do
      cond do
        user && user.email == invitee_email ->
          accept_by_matched_user(conn, user, invitation)

        user && user.email != invitee_email ->
          accept_by_unmatched_user(conn, token)

        true ->
          accept_by_unregistered_user(conn, invitee_email, token)
      end
    else
      {:error, %Ecto.NoResultsError{}} ->
        conn
        |> put_flash(:error, "Invalid or expired invitation")
        |> redirect(to: "/")
    end
  end

  defp accept_by_matched_user(conn, user, invitation) do
    case Invitations.accept_invitation(user, invitation) do
      {:ok, _} ->
        redirect(conn, to: ~p"/team")

      {:error, reason} ->
        conn |> put_flash(:error, reason) |> redirect(to: ~p"/")
    end
  end

  defp accept_by_unmatched_user(conn, token) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/?invitation_token=#{token}")
  end

  defp accept_by_unregistered_user(conn, invitee_email, token) do
    conn
    |> put_flash(
      :info,
      "This invite is for #{invitee_email}, please sign in with that account"
    )
    |> redirect(to: ~p"/?invitation_token=#{token}")
  end

  def put_invitation_token(
        %Plug.Conn{params: %{"invitation_token" => token}} = conn,
        _
      ) do
    put_session(conn, :invitation_token, token)
  end

  def put_invitation_token(conn, _) do
    conn
  end
end
