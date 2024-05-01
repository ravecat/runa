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
    socket =
      assign_new(socket, :user, fn ->
        Runa.Repo.get_by(Accounts.User, email: user.email)
        |> Runa.Repo.preload(:teams)
      end)

    {:cont, socket}
  end
end
