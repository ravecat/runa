defmodule RunaWeb.InvitationControllerTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :invitation

  setup do
    inviter = insert(:user)
    team = insert(:team)

    {:ok, inviter: inviter, team: team}
  end

  describe "accept an invitation link with pending token" do
    test "by an invitee authenticated user", ctx do
      invitee = insert(:user)

      invitation =
        insert(:invitation,
          invited_by_user: ctx.inviter,
          team: ctx.team,
          email: invitee.email
        )

      conn =
        put_session(ctx.conn, :user_id, invitee.id)
        |> get(~p"/invitations/accept/#{invitation.token}")

      assert redirected_to(conn) == ~p"/team"
      assert Phoenix.Flash.get(conn.assigns[:flash], :info) == nil
    end

    test "by an another authenticated user", ctx do
      invitee = insert(:user)
      user = insert(:user)

      invitation =
        insert(:invitation,
          invited_by_user: ctx.inviter,
          team: ctx.team,
          email: invitee.email
        )

      conn =
        put_session(ctx.conn, :user_id, user.id)
        |> get(~p"/invitations/accept/#{invitation.token}")

      assert redirected_to(conn) == ~p"/?invitation_token=#{invitation.token}"

      conn = recycle(conn) |> get(~p"/")

      assert get_session(conn, :user_id) == nil
    end

    test "by an unauthenticated user", ctx do
      invitee = insert(:user)

      invitation =
        insert(:invitation,
          invited_by_user: ctx.inviter,
          team: ctx.team,
          email: invitee.email
        )

      conn = get(ctx.conn, ~p"/invitations/accept/#{invitation.token}")

      assert redirected_to(conn) == ~p"/?invitation_token=#{invitation.token}"

      assert Phoenix.Flash.get(conn.assigns[:flash], :info) =~
               "This invite is for #{invitee.email}, please sign in with that account"
    end
  end

  test "accept a invitation link with invalid token", ctx do
    conn = get(ctx.conn, ~p"/invitations/accept/invalid")

    assert redirected_to(conn) == "/"

    assert Phoenix.Flash.get(conn.assigns[:flash], :error) =~
             "Invalid or expired invitation"
  end

  describe "invitation request" do
    test "puts invitation token in assigns", ctx do
      conn = get(ctx.conn, ~p"/?invitation_token=token123")

      assert get_session(conn, :invitation_token) == "token123"
    end
  end
end
