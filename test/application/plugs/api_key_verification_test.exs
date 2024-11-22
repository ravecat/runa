defmodule RunaWeb.Plugs.APIKeyVerificationTest do
  use RunaWeb.ConnCase
  use RunaWeb.OpenAPICase

  alias RunaWeb.JSONAPI
  alias RunaWeb.Plugs.APIKeyVerification

  setup do
    %{user: insert(:user)}
  end

  test "returns 401 error if no api key is provided", ctx do
    conn =
      ctx.conn
      |> Map.put(:method, "GET")
      |> bypass_through()
      |> Phoenix.Controller.accepts(["jsonapi"])
      |> APIKeyVerification.call([])

    assert conn.halted

    assert_schema(json_response(conn, 401), "Error", ctx.spec)
  end

  test "returns 401 error if invalid api key is provided", ctx do
    conn =
      ctx.conn
      |> put_req_header(JSONAPI.Headers.api_key(), "invalid")
      |> Map.put(:method, "GET")
      |> bypass_through()
      |> Phoenix.Controller.accepts(["jsonapi"])
      |> APIKeyVerification.call([])

    assert conn.halted

    assert_schema(json_response(conn, 401), "Error", ctx.spec)
  end

  describe "GET request" do
    test "allows access if api key has write access", ctx do
      token = insert(:token, user: ctx.user, access: :write)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "GET")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "allows access if api key has read access", ctx do
      token = insert(:token, user: ctx.user, access: :read)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "GET")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "does not allow access if api key is suspended", ctx do
      token = insert(:token, user: ctx.user, access: :suspended)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "GET")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      assert conn.status == 403
      assert conn.halted
    end
  end

  describe "POST request" do
    test "allows access if api key has write access", ctx do
      token = insert(:token, user: ctx.user, access: :write)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "POST")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "does not allow access if api key has read access", ctx do
      token = insert(:token, user: ctx.user, access: :read)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "POST")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      assert conn.status == 403
      assert conn.halted
    end
  end

  describe "PUT request" do
    test "allows access if api key has write access", ctx do
      token = insert(:token, user: ctx.user, access: :write)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "PUT")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "does not allow access if api key has read access", ctx do
      token = insert(:token, user: ctx.user, access: :read)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "PUT")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      assert conn.status == 403
      assert conn.halted
    end
  end

  describe "PATCH request" do
    test "allows access if api key has write access", ctx do
      token = insert(:token, user: ctx.user, access: :write)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "PATCH")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "does not allow access if api key has read access", ctx do
      token = insert(:token, user: ctx.user, access: :read)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "PATCH")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      assert conn.status == 403
      assert conn.halted
    end
  end

  describe "DELETE request" do
    test "allows access if api key has write access", ctx do
      token = insert(:token, user: ctx.user, access: :write)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "DELETE")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      refute conn.halted
    end

    test "does not allow access if api key has read access", ctx do
      token = insert(:token, user: ctx.user, access: :read)

      conn =
        ctx.conn
        |> put_req_header(JSONAPI.Headers.api_key(), token.token)
        |> Map.put(:method, "DELETE")
        |> bypass_through()
        |> Phoenix.Controller.accepts(["jsonapi"])
        |> APIKeyVerification.call([])

      assert conn.status == 403
      assert conn.halted
    end
  end
end
