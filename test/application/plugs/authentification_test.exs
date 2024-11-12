defmodule RunaWeb.Plugs.AuthenticationTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true

  alias Runa.Accounts
  alias RunaWeb.Plugs.Authentication

  setup do
    %{user: insert(:user)}
  end

  describe "plug initialization" do
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

      conn =
        put_session(ctx.conn, :user_id, ctx.user.id)
        |> Authentication.call([])

      assert conn.assigns.current_user == ctx.user
    end

    @tag :only
    test "assigns nil to current_user when user_id not present in session",
         ctx do
      conn = Authentication.call(ctx.conn, [])

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

  describe "authenticate data processing" do
    test "fetches uid" do
      auth_data = %Ueberauth.Auth{uid: "123"}

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.uid == "123"

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "fetches avatar from avatar_url" do
      auth_data = %Ueberauth.Auth{
        info: %{
          urls: %{avatar_url: "https://example.com/avatar.jpg"}
        }
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.avatar == "https://example.com/avatar.jpg"

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "fetches avatar from image" do
      auth_data = %Ueberauth.Auth{
        info: %{image: "https://example.com/avatar.jpg"}
      }

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.avatar == "https://example.com/avatar.jpg"

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
    end

    test "returns nil when no avatar is available" do
      auth_data = %Ueberauth.Auth{}

      Repatch.patch(Accounts, :create_or_find, fn params ->
        assert params.avatar == nil

        {:ok, %Accounts.User{}}
      end)

      Authentication.authenticate_by_auth_data(auth_data)
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
        assert params.name == nil
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
