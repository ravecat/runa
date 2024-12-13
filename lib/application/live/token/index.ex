defmodule RunaWeb.Live.Token.Index do
  @moduledoc """
  This module is responsible for the token index listing.
  """

  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Accounts.User
  alias Runa.Tokens
  alias Runa.Tokens.Token

  import RunaWeb.Components.Table
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Table
  import RunaWeb.Components.Modal
  import RunaWeb.Formatters
  import RunaWeb.Components.Card

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    handle_user_data(user_id, socket)
  end

  defp handle_user_data(user_id, socket) do
    case Accounts.get(user_id) do
      {:ok, user} -> handle_actual_user_data(socket, user)
      {:error, %Ecto.NoResultsError{}} -> handle_missing_user_data(socket)
      _ -> {:ok, redirect(socket, to: ~p"/")}
    end
  end

  defp handle_actual_user_data(socket, user) do
    if connected?(socket) do
      PubSub.subscribe("tokens:#{user.id}")
      PubSub.subscribe("accounts:#{user.id}")
    end

    user = Repo.preload(user, tokens: :user)

    socket =
      socket
      |> assign(:is_visible_delete_token_modal, false)
      |> assign(:is_visible_token_modal, false)
      |> assign(:user, user)
      |> assign_new(:access, fn ->
        Enum.map(Token.access_levels(), fn {label, _} -> {label, label} end)
      end)
      |> assign(token: %Token{})
      |> stream(:tokens, user.tokens)

    {:ok, socket}
  end

  defp handle_missing_user_data(socket) do
    socket =
      socket
      |> put_flash(:error, "User not found")
      |> redirect(to: ~p"/")

    {:ok, socket}
  end

  @impl true
  def handle_info({:created_token, %Token{} = data}, socket) do
    data = Repo.preload(data, :user)

    socket =
      socket
      |> stream_insert(:tokens, data)
      |> assign(:token, %Token{})
      |> assign(:is_visible_token_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:updated_token, %Token{} = data}, socket) do
    data = Repo.preload(data, :user)

    socket =
      socket
      |> stream_delete(:tokens, data)
      |> stream_insert(:tokens, data)
      |> assign(:token, %Token{})
      |> assign(:is_visible_token_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:updated_account, %User{} = data}, socket) do
    data = Repo.preload(data, [tokens: :user], force: true)

    socket =
      stream(socket, :tokens, data.tokens, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("open_delete_token_modal", %{"id" => id}, socket) do
    case Tokens.get(id) do
      {:ok, data} ->
        socket =
          socket
          |> assign(:token, data)
          |> assign(:is_visible_delete_token_modal, true)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete token")}
    end
  end

  @impl true
  def handle_event("close_delete_token_modal", _, socket) do
    socket =
      socket
      |> assign(:token, %Token{})
      |> assign(:is_visible_delete_token_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_token_modal", %{"id" => id}, socket) do
    case Tokens.get(id) do
      {:ok, token} ->
        socket =
          socket
          |> assign(:token, token)
          |> assign(:is_visible_token_modal, true)

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_token_modal", _, socket) do
    {:noreply, assign(socket, :is_visible_token_modal, true)}
  end

  @impl true
  def handle_event("close_token_modal", _, socket) do
    socket =
      socket
      |> assign(:token, %Token{})
      |> assign(:is_visible_token_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_token", _, socket) do
    case Tokens.delete(socket.assigns.token.id) do
      {:ok, data} ->
        socket =
          socket
          |> stream_delete(:tokens, data)
          |> assign(:token, %Token{})
          |> assign(:is_visible_delete_token_modal, false)

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
