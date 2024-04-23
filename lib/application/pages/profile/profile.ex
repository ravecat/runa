defmodule RunaWeb.PageLive.Profile do
  use RunaWeb, :live_view
  use RunaWeb, :components

  alias Runa.Accounts

  @impl true
  def mount(_params, %{"current_user" => user}, socket) do
    user =
      case Runa.Repo.get_by(Accounts.User, email: user.email) do
        %Accounts.User{} = user -> user |> Runa.Repo.preload(:teams)
        _ -> %Accounts.User{}
      end

    [active_team | _tail] = user.teams

    socket =
      socket
      |> assign(:user, user)
      |> assign(:teams, user.teams)
      |> assign(:active_team, active_team)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, %{assigns: %{live_action: :show}} = socket) do
    socket =
      socket
      |> assign(:page_title, "Profile")

    {:noreply, socket}
  end

  def handle_params(%{"id" => id}, _url, %{assigns: %{live_action: :edit}} = socket) do
    socket =
      socket
      |> assign(:page_title, "Edit profile")
      |> assign(:user, Accounts.get_user!(id))

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
