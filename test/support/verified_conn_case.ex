defmodule RunaWeb.VerifiedConnCase do
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
