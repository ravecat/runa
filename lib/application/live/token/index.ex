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
  import RunaWeb.Components.Modal

  on_mount RunaWeb.Scope
  on_mount __MODULE__

  def on_mount(_, _, _, socket) do
    if connected?(socket) do
      Tokens.subscribe(socket.assigns.user.id)
      Accounts.subscribe(socket.assigns.scope)
    end

    {:cont, socket}
  end

  @impl true
  def mount(_, _, %{assigns: %{user: user}} = socket) do
    user = Repo.preload(user, tokens: :user)

    socket =
      socket
      |> assign(user: user, access: Tokens.get_access_labels())
      |> stream(:tokens, user.tokens)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _) do
    assign(socket, token: build_token(socket.assigns.user.id))
  end

  defp apply_action(socket, action, %{"id" => id})
       when action in [:edit, :delete] do
    {:ok, data} = Tokens.get(id)

    assign(socket, token: data)
  end

  defp apply_action(socket, _, _) do
    socket
  end

  @impl true
  def handle_info({:token_created, %Token{} = data}, socket) do
    socket = socket |> stream_insert(:tokens, data) |> assign(:token, %Token{})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:token_updated, %Token{} = data}, socket) do
    socket =
      socket
      |> stream_delete(:tokens, data)
      |> stream_insert(:tokens, data)
      |> assign(:token, %Token{})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:account_updated, %User{} = data}, socket) do
    data = Repo.preload(data, [tokens: :user], force: true)

    socket = stream(socket, :tokens, data.tokens, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_token", %{"id" => id}, socket) do
    case Tokens.delete(id) do
      {:ok, data} ->
        socket =
          stream_delete(socket, :tokens, data) |> push_patch(to: ~p"/tokens")

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete token")}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  defp build_token(user_id) do
    %Token{user_id: user_id}
  end
end
