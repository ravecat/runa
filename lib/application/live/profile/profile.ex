defmodule RunaWeb.Live.Profile do
  @moduledoc """
  This module is responsible for the profile page and user data management.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts

  import RunaWeb.Components.Tab
  import RunaWeb.Components.Info
  import RunaWeb.Components.Avatar

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket) do
      PubSub.subscribe("tokens:#{user_id}")
    end

    case Accounts.get(user_id) do
      {:ok, user} ->
        socket =
          assign(socket,
            user: user
          )

        {:ok, socket}

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
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end
