defmodule RunaWeb.SessionControllerTest do
  use RunaWeb.ConnCase, async: true

  alias RunaWeb.SessionController

  @moduletag :session

  setup do
    {:ok,
     auth_data: %Ueberauth.Auth{
       uid: "1234567890",
       credentials: %{token: "fdsnoafhnoofh08h38h"},
       provider: :google,
       info: %Ueberauth.Auth.Info{name: "John Doe", email: "john@mail.com"}
     },
     user: insert(:user)}
  end

  describe "session controller" do
    test "redirects user to Google for authentication", ctx do
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
        |> assign(:ueberauth_auth, ctx.auth_data)
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
end
