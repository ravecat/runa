defmodule RunaWeb.Scope do
  @moduledoc """
  Assigns the data to the live view scope.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts

  def on_mount(_, _, %{"user_id" => user_id}, socket) do
    case Accounts.get(user_id) do
      {:ok, user} ->
        {:cont,
         Phoenix.Component.assign(socket,
           scope: Runa.Scope.new(user),
           user: user
         )}

      _ ->
        handle_missing_user_data(socket)
    end
  end

  def on_mount(_, _, _, socket), do: handle_missing_user_data(socket)

  defp handle_missing_user_data(socket) do
    socket =
      socket |> put_flash(:error, "User not found") |> redirect(to: ~p"/")

    {:halt, socket}
  end
end
