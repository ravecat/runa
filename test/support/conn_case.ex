defmodule RunaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use RunaWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  @session_opts Plug.Session.init(
                  store: :cookie,
                  key: "_session",
                  encryption_salt: "encrypted cookie salt",
                  signing_salt: "signing salt",
                  secret_key_base: String.duplicate("abcdef0123456789", 8),
                  same_site: "Lax"
                )

  using do
    quote do
      # The default endpoint for testing
      @endpoint RunaWeb.Endpoint

      use RunaWeb, :verified_routes
      use ExUnit.Case

      # Import conveniences for testing with connections
      import Plug.Conn
      import Plug.HTML
      import Phoenix.ConnTest
      import RunaWeb.ConnCase
    end
  end

  setup tags do
    Runa.DataCase.setup_sandbox(tags)

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Session.call(@session_opts)
      |> Plug.Conn.fetch_session()
      |> Phoenix.Controller.fetch_flash()

    {:ok, conn: conn}
  end
end
