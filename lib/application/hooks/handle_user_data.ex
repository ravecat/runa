defmodule RunaWeb.HandleUserData do
  @moduledoc """
  Hook module for handling user data to the application.

  This module provides functionality to:
  - Mount user data to the socket based on the user_id parameter
  - Handle cases where user data is missing or cannot be retrieved
  - Redirect users to the home page with an error message when user data is not found
  """

  use RunaWeb, :live_view

  alias Runa.Accounts

  def on_mount(_, _, %{"user_id" => user_id}, socket),
    do: handle_user_data(user_id, socket)

  def on_mount(_, _, _, socket), do: handle_missing_user_data(socket)

  defp handle_user_data(user_id, socket) do
    case Accounts.get(user_id) do
      {:ok, user} -> {:cont, assign(socket, user: user)}
      _ -> handle_missing_user_data(socket)
    end
  end

  defp handle_missing_user_data(socket) do
    socket =
      socket |> put_flash(:error, "User not found") |> redirect(to: ~p"/")

    {:halt, socket}
  end
end
