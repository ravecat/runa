defmodule RunaWeb.FeatureCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a full browser.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @moduledoc false

      @moduletag :e2e

      use Wallaby.Feature
      use Repatch.ExUnit

      import Wallaby.Query
      import Runa.Factory
      import Wallaby.Browser
      import unquote(__MODULE__)

      alias Runa.Repo
      alias Runa.Scope
    end
  end

  @spec put_session(Wallaby.Session.t(), atom(), term()) :: Wallaby.Session.t()
  def put_session(session, key, value) do
    endpoint_opts = Application.get_env(:runa, RunaWeb.Endpoint)
    secret_key_base = Keyword.fetch!(endpoint_opts, :secret_key_base)
    session_opts = Keyword.fetch!(endpoint_opts, :session_options)
    cookie_key = Keyword.fetch!(session_opts, :key)

    conn =
      %Plug.Conn{secret_key_base: secret_key_base}
      |> Plug.Session.call(Plug.Session.init(session_opts))
      |> Plug.Conn.fetch_session()
      |> Plug.Conn.put_session(key, value)
      |> Plug.Conn.resp(:ok, "")
      |> then(fn conn ->
        Enum.reduce_while(conn.private.before_send || [], conn, fn fun, acc ->
          {:cont, fun.(acc)}
        end)
      end)

    resp_cookie = conn.resp_cookies[cookie_key][:value]

    session
    |> Wallaby.Browser.visit("/")
    |> Wallaby.Browser.set_cookie(cookie_key, resp_cookie)
  end
end
