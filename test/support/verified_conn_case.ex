defmodule RunaWeb.VerifiedConnCase do
  @moduledoc """
  This module is responsible for setting up a connection with a verified API key.

  Require for test cases with verified API key.
  """
  use ExUnit.CaseTemplate

  import Runa.Factory

  setup ctx do
    token = Runa.Tokens.generate()

    conn =
      Plug.Conn.put_req_header(
        ctx.conn,
        RunaWeb.JSONAPI.Headers.api_key(),
        token
      )

    insert(:token, user: fn -> build(:user) end, token: token, access: :write)

    {:ok, conn: conn}
  end
end
