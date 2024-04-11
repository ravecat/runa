defmodule RunaWeb.UserLive.Index do
  use RunaWeb, :live_view

  alias Runa.Accounts

  @impl true
  def mount(_params, %{"current_user" => user}, socket) do
    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, %{assigns: %{live_action: :edit}} = socket) do
    socket =
      socket
      |> assign(:page_title, "Edit profile")
      |> assign(:user, Accounts.get_user!(id))

    {:noreply, socket}
  end

  def handle_params(_params, _url, %{assigns: %{live_action: :index}} = socket) do
    socket =
      socket
      |> assign(:page_title, "Profile")

    {:noreply, socket}
  end

  @impl true
  def handle_info({RunaWeb.UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
