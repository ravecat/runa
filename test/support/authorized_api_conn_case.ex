defmodule RunaWeb.AuthorizedAPIConnCase do
  @moduledoc """
  This module is responsible for setting up a connection with a verified API key.

  Require for test cases with verified API key.
  """
  use ExUnit.CaseTemplate

  import Runa.Factory

  setup ctx do
    token = insert(:token, user: fn -> build(:user) end, access: :write)

    conn =
      Plug.Conn.put_req_header(
        ctx.conn,
        RunaWeb.JSONAPI.Headers.api_key(),
        token.token
      )

    {:ok, conn: conn}
  end
end
