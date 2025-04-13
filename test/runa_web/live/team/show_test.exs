defmodule RunaWeb.Live.Team.ShowTest do
  use RunaWeb.FeatureCase, auth: true

  @moduletag :teams

  @session_opts Plug.Session.init(
                  store: :cookie,
                  key: "_session",
                  encryption_salt: "encrypted cookie salt",
                  signing_salt: "signing salt",
                  secret_key_base: String.duplicate("abcdef0123456789", 8),
                  same_site: "Lax"
                )

  setup ctx do
    team = insert(:team)
    scope = Scope.new(ctx.user)
    owner = insert(:contributor, team: team, user: ctx.user, role: :owner)

    contributors =
      insert_list(3, :contributor,
        team: team,
        user: fn -> insert(:user) end,
        role: :editor
      )

    members = Enum.map(contributors, &{&1.user, &1}) ++ [{owner.user, owner}]

    {:ok,
     members: members, scope: scope, owner: owner, contributors: contributors}
  end

  describe "team dashboard" do
    @tag :only
    feature "put cookie directly", ctx do
      endpoint_opts = Application.get_env(:runa, RunaWeb.Endpoint)
      secret_key_base = Keyword.fetch!(endpoint_opts, :secret_key_base)

      conn =
        %Plug.Conn{secret_key_base: secret_key_base}
        |> Plug.Conn.put_resp_cookie("_runa_key", %{user_id: ctx.user.id},
          sign: true
        )

      resp_cookie = conn.resp_cookies["_runa_key"][:value]

      dbg("==========TEST===========")
      IO.puts("resp_cookie: #{inspect(resp_cookie)}\n")

      [_, payload, _] = String.split(resp_cookie, ".", parts: 3)
      {:ok, encoded_cookie_data} = Base.url_decode64(payload, padding: false)

      IO.puts(
        "encoded resp_cookie: #{inspect(:erlang.binary_to_term(encoded_cookie_data))}\n\n"
      )

      ctx.session
      |> visit("/")
      |> set_cookie("_runa_key", resp_cookie)
      |> visit("/team")
      |> assert_has(Query.css("[aria-label='Team members']"))
    end

    feature "put cookie via session", ctx do
      endpoint_opts = Application.get_env(:runa, RunaWeb.Endpoint)
      secret_key_base = Keyword.fetch!(endpoint_opts, :secret_key_base)

      conn =
        %Plug.Conn{secret_key_base: secret_key_base}
        |> Plug.Session.call(@session_opts)
        |> Plug.Conn.fetch_session()
        |> Plug.Conn.put_session(:user_id, ctx.user.id)
        |> Plug.Conn.resp(:ok, "")

      resp_cookie = conn.resp_cookies["_session"][:value]

      dbg("==========TEST===========")
      IO.puts("resp_cookie: #{inspect(resp_cookie)}\n")

      [_, payload, _] = String.split(resp_cookie, ".", parts: 3)
      {:ok, encoded_cookie_data} = Base.url_decode64(payload, padding: false)

      IO.puts(
        "encoded resp_cookie: #{inspect(:erlang.binary_to_term(encoded_cookie_data))}\n\n"
      )

      ctx.session
      |> visit("/")
      |> set_cookie("_runa_key", resp_cookie)
      |> visit("/team")
      |> assert_has(Query.css("[aria-label='Team members']"))
    end
  end
end
