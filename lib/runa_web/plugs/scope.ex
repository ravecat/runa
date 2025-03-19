defmodule RunaWeb.Plugs.Scope do
  @moduledoc """
  Plug to extend the connection with a user scope.
  """
  import Plug.Conn

  use RunaWeb, :controller

  alias Runa.Scope

  def call(conn, _opts) do
    case conn.assigns[:current_user] do
      %Runa.Accounts.User{} = user -> assign(conn, :scope, Scope.new(user))
      _ -> assign(conn, :scope, Scope.new(nil))
    end
  end
end
