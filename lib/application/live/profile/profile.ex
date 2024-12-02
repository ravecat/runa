defmodule RunaWeb.Live.Profile do
  @moduledoc """
  This module is responsible for the profile page and user data management.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Tokens
  alias Runa.Tokens.Token

  import RunaWeb.Components.Dropdown
  import RunaWeb.Components.Tab
  import RunaWeb.Components.Info
  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Table
  import RunaWeb.Components.Modal
  import RunaWeb.Formatters

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket) do
      PubSub.subscribe("tokens:#{user_id}")
    end

    case Accounts.get(user_id) do
      {:ok, user} ->
        socket =
          socket
          |> assign(:is_visible_delete_token_modal, false)
          |> assign(access_levels: Token.access_levels())
          |> assign(user: user)
          |> stream(:tokens, user.tokens)

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
  def handle_event("open_delete_token_modal", %{"id" => id}, socket) do
    socket =
      socket
      |> assign(:token_id_to_delete, id)
      |> assign(:is_visible_delete_token_modal, true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("close_delete_token_modal", _, socket) do
    {:noreply, assign(socket, :is_visible_delete_token_modal, false)}
  end

  @impl true
  def handle_event("delete_token", %{"id" => id}, socket) do
    case Tokens.delete(id) do
      {:ok, data} ->
        socket =
          socket
          |> stream_delete(:tokens, data)
          |> assign(:is_visible_delete_token_modal, false)
          |> assign(:token_id_to_delete, nil)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete token")}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end
