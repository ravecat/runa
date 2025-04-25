defmodule RunaWeb.SessionControllerTest do
  use RunaWeb.ConnCase, async: true

  alias RunaWeb.SessionController

  @moduletag :session

  setup do
    {:ok, user: insert(:user)}
  end

  describe "session controller" do
    test "redirects user to Google provider for authentication", ctx do
      conn = get(ctx.conn, "/session/google")

      assert redirected_to(conn, 302)
    end

    test "puts user id to session on authentication success", ctx do
      Repatch.patch(
        RunaWeb.Plugs.Authentication,
        :authenticate_by_auth_data,
        fn _ -> {:ok, ctx.user} end
      )

      conn =
        ctx.conn
        |> assign(:ueberauth_auth, %Ueberauth.Auth{})
        |> SessionController.callback(%{})

      assert get_session(conn, :user_id) == ctx.user.id
    end

    test "redirects user on authentication failure", ctx do
      conn =
        ctx.conn
        |> assign(:ueberauth_failure, %{errors: [error: "Invalid credentials"]})
        |> SessionController.callback(%{})

      assert redirected_to(conn) == "/"
    end

    test "shows message on authentication failure", ctx do
      conn =
        ctx.conn
        |> assign(:ueberauth_failure, %{errors: [error: "Invalid credentials"]})
        |> SessionController.callback(%{})

      assert Flash.get(conn.assigns.flash, :error) == "Failed to authenticate."
    end

    test "redirect on logout", ctx do
      conn = delete(ctx.conn, ~p"/session/logout")

      assert redirected_to(conn) == "/"
    end
  end

  describe "session controller with invitation" do
    test "binds invitation team with invitee", ctx do
      inviter = insert(:user)
      invitee = insert(:user)
      team = insert(:team)

      Repatch.patch(
        RunaWeb.Plugs.Authentication,
        :authenticate_by_auth_data,
        fn _ -> {:ok, invitee} end
      )

      invitation =
        insert(:invitation,
          invited_by_user: inviter,
          team: team,
          email: invitee.email
        )

      assert {:error, _} =
               Runa.Contributors.get_by(user_id: invitee.id, team_id: team.id)

      conn =
        put_session(ctx.conn, :invitation_token, invitation.token)
        |> assign(:ueberauth_auth, %Ueberauth.Auth{})
        |> SessionController.callback(%{})

      assert get_session(conn, :invitation_token) == nil

      assert {:ok, _} =
               Runa.Contributors.get_by(user_id: invitee.id, team_id: team.id)
    end
  end
end
