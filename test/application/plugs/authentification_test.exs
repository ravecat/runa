defmodule RunaWeb.Plugs.AuthenticationTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias Runa.Accounts
  alias RunaWeb.Plugs.Authentication

  setup do
    %{user: insert(:user)}
  end

  describe "authentication plug" do
    test "re-assigns user when already existing in connection", ctx do
      conn =
        ctx.conn
        |> assign(:current_user, ctx.user)
        |> Authentication.call([])

      assert conn.assigns.current_user == ctx.user
      assert is_binary(conn.assigns.user_token)
    end

    test "assigns user from db when user_id present in session", ctx do
      Repatch.patch(Accounts, :get, fn _ -> {:ok, ctx.user} end)

      conn = Authentication.call(ctx.conn, [])

      assert conn.assigns.current_user == ctx.user
    end

    test "assigns nil to current_user when user_id not present in session",
         ctx do
      conn =
        ctx.conn |> put_session(:user_id, nil) |> Authentication.call([])

      assert conn.assigns.current_user == nil
      refute Map.has_key?(conn.assigns, :user_token)
    end
  end

  describe "authenticate/2" do
    test "returns connection when current_user is assigned", ctx do
      conn =
        ctx.conn
        |> assign(:current_user, ctx.user)
        |> Authentication.authenticate([])

      assert conn.assigns.current_user == ctx.user
    end

    test "halts request when current_user is not assigned", ctx do
      conn = Authentication.authenticate(ctx.conn, [])

      assert conn.halted
    end

    test "redirects to root path when current_user is not assigned", ctx do
      conn = Authentication.authenticate(ctx.conn, [])

      assert redirected_to(conn) == "/"
    end
  end

  describe "authentication data processing" do
    test "fetches uid" do
      auth_data = %Ueberauth.Auth{uid: "123"}

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.uid == "123"

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "uses side avatar service" do
      auth_datas = [
        %Ueberauth.Auth{
          info: %{
            urls: %{avatar_url: "https://example.com/avatar.jpg"}
          }
        },
        %Ueberauth.Auth{
          info: %{image: "https://example.com/avatar.jpg"}
        },
        %Ueberauth.Auth{}
      ]

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.avatar =~
                 "https://api.dicebear.com/9.x/thumbs/svg?seed="

        {:ok, %Accounts.User{}}
      end)

      for auth_data <- auth_datas do
        Authentication.authenticate_by_auth_data(auth_data)
      end
    end

    test "fetches email from auth info" do
      auth_data = %Ueberauth.Auth{
        info: %{email: "user@example.com"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.email == "user@example.com"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "returns nil when no email is available" do
      auth_data = %Ueberauth.Auth{
        info: %{}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.email == nil
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "fetches name directly when available" do
      auth_data = %Ueberauth.Auth{
        info: %{name: "John Doe"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "John Doe"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "constructs name from first_name and last_name" do
      auth_data = %Ueberauth.Auth{
        info: %{
          first_name: "John",
          last_name: "Doe"
        }
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "John Doe"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "uses only first_name when last_name is missing" do
      auth_data = %Ueberauth.Auth{
        info: %{
          first_name: "John",
          last_name: nil
        }
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "John"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "uses nickname as name when no other name info available" do
      auth_data = %Ueberauth.Auth{
        info: %{nickname: "johndoe"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "johndoe"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "uses email as name when no other name info available" do
      auth_data = %Ueberauth.Auth{
        info: %{email: "john@example.com"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "john@example.com"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "returns nil when no name info is available" do
      auth_data = %Ueberauth.Auth{
        info: %{}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.name == "Anonymous"

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "fetches nickname when available" do
      auth_data = %Ueberauth.Auth{
        info: %{nickname: "johndoe"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.nickname == "johndoe"
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "returns nil when no nickname is available" do
      auth_data = %Ueberauth.Auth{
        info: %{}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.nickname == nil
        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end
  end
end
