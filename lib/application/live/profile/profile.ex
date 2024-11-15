defmodule RunaWeb.Live.Profile do
  use RunaWeb, :live_view
  use RunaWeb, :components

  alias Runa.Accounts

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    case Accounts.get(user_id) do
      {:ok, user} ->
        {:ok, assign(socket, :user, user)}

      {:error, %Ecto.NoResultsError{}} ->
        socket =
          socket
          |> put_flash(:error, "User not found")
          |> redirect(to: ~p"/")

        {:ok, socket}

      _ ->
        {:ok, redirect(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_params(
        _params,
        _url,
        %{assigns: %{live_action: :show}} = socket
      ) do
    {:noreply, assign(socket, :page_title, "Profile")}
  end

  @impl true
  def handle_params(
        %{"id" => _},
        _url,
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:noreply, assign(socket, :page_title, "Edit profile")}
  end
end
