defmodule RunaWeb.PageLive.Profile do
  use RunaWeb, :live_view
  use RunaWeb, :components

  alias Runa.Accounts
  alias RunaWeb.UserLive.FormComponent

  @impl true
  def handle_params(
        _params,
        _url,
        %{assigns: %{live_action: :show, user: user}} = socket
      ) do
    socket =
      assign(socket, %{
        page_title: "Profile",
        user: user
      })

    {:noreply, socket}
  end

  def handle_params(
        %{"id" => id},
        _url,
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:ok, user} = Accounts.get(id)

    socket =
      socket
      |> assign(:page_title, "Edit profile")
      |> assign(:user, user)

    {:noreply, socket}
  end

  @impl true
  def handle_info({FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, user} = Accounts.get(id)

    {:ok, _} = Accounts.delete(user)

    {:noreply, stream_delete(socket, :users, user)}
  end
end
