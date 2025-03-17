defmodule RunaWeb.Plugs.Scope do
  import Plug.Conn

  use RunaWeb, :controller

  alias Runa.Scope

  def call(conn, _opts) do
    cond do
      user = conn.assigns[:current_user] ->
        assign(conn, :scope, Scope.new(user))

      true ->
        assign(conn, :scope, Scope.new(nil))
    end
  end
end
