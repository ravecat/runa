defmodule RunaWeb.Live.Profile do
  @moduledoc """
  This module is responsible for the profile page and user data management.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts

  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Card
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Input
  import RunaWeb.Components.Form
  import RunaWeb.Formatters

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket) do
      PubSub.subscribe("tokens:#{user_id}")
    end

    case Accounts.get(user_id) do
      {:ok, user} ->
        formatted_user = %{
          user
          | inserted_at: format_datetime_to_view(user.inserted_at),
            updated_at: format_datetime_to_view(user.updated_at)
        }

        socket =
          assign_new(socket, :user_form_data, fn ->
            to_form(Accounts.change(formatted_user))
          end)
          |> assign(:user, formatted_user)

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
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end
end
