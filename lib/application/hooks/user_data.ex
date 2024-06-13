defmodule RunaWeb.UserData do
  @moduledoc """
  Helper module for user data.

  This module is used to fetch user data from the database and assign it to the socket.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts

  def on_mount(
        :default,
        _params,
        %{"current_user" => user},
        socket
      ) do
    {:cont,
     assign_new(socket, :user, fn ->
       Accounts.get_user_by(email: user.email)
     end)}
  end
end
