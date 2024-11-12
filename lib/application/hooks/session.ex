defmodule RunaWeb.Session do
  @moduledoc """
  Helper module for session data.

  This module is used to assign common session data to the socket.
  """
  use RunaWeb, :live_view
  alias Runa.Accounts

  def on_mount(:user, _params, session, socket) do
    case Accounts.get(session["user_id"]) do
      {:ok, user} -> {:cont, assign(socket, :user, user)}
      {:error, _reason} -> {:halt, redirect(socket, to: "/")}
    end
  end

  def on_mount(:default, params, session, socket) do
    on_mount(:user, params, session, socket)
  end
end
