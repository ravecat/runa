defmodule RunaWeb.InvitationController do
  use RunaWeb, :controller
  use RunaWeb, :verified_routes

  alias Runa.Invitations

  def accept(conn, %{"token" => token}) do
    case Invitations.get_invitation(token) do
      {:error, %Ecto.NoResultsError{}} ->
        conn
        |> put_flash(:error, "Invalid or expired invitation")
        |> redirect(to: "/")

      {:ok, invitation} ->
        user = conn.assigns[:current_user]
        invitee_email = invitation.email

        cond do
          user && user.email == invitee_email ->
            case Invitations.accept_invitation(user, invitation) do
              {:ok, _} ->
                redirect(conn, to: ~p"/team")

              {:error, reason} ->
                conn |> put_flash(:error, reason) |> redirect(to: ~p"/")
            end

          user && user.email != invitee_email ->
            conn
            |> configure_session(drop: true)
            |> redirect(to: ~p"/?invitation_token=#{token}")

          true ->
            conn
            |> put_flash(
              :info,
              "This invite is for #{invitee_email}, please sign in with that account"
            )
            |> redirect(to: ~p"/?invitation_token=#{token}")
        end
    end
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
