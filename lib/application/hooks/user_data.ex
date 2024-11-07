defmodule RunaWeb.UserData do
  @moduledoc """
  Helper module for user data.

  This module is used to fetch user data from the database and assign it to the socket.
  """
  use RunaWeb, :live_view
  alias Runa.Accounts

  def on_mount(:default, _params, session, socket) do
    case session do
      %{"user_id" => user_id} when not is_nil(user_id) ->
        {:cont,
         assign_new(socket, :user, fn ->
           Accounts.get_user!(user_id)
         end)}

      _ ->
        {:halt, redirect(socket, to: "/")}
    end
  end
end
