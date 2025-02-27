defmodule RunaWeb.Live.Profile do
  @moduledoc """
  This module is responsible for the profile page and user data management.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Services.Avatar
  alias Runa.Tokens

  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Card
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Input
  import RunaWeb.Components.Form
  import RunaWeb.Formatters

  @impl true
  def mount(_, _, %{assigns: %{user: user}} = socket) do
    if connected?(socket) do
      Tokens.subscribe(user.id)
    end

    socket =
      assign_new(socket, :user_form_data, fn -> prepare_user_form(user) end)

    {:ok, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => attrs}, socket) do
    changeset =
      Accounts.change(socket.assigns.user, attrs)

    {:noreply,
     assign(socket, user_form_data: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("delete_avatar", _, socket) do
    value = Avatar.generate_url(socket.assigns.user.name, style: :initials)

    handle_event("save", %{"user" => %{avatar: value}}, socket)
  end

  @impl true
  def handle_event("save", %{"field" => "avatar"}, socket) do
    value = Avatar.generate_random_url()

    handle_event("save", %{"user" => %{avatar: value}}, socket)
  end

  @impl true
  def handle_event("save", %{"value" => value, "field" => field}, socket) do
    handle_event("save", %{"user" => %{field => value}}, socket)
  end

  @impl true
  def handle_event("save", %{"user" => attrs}, socket) do
    case Accounts.update(socket.assigns.user, attrs) do
      {:ok, user} ->
        user = Repo.preload(user, tokens: :user)

        socket =
          socket
          |> assign(:user, user)
          |> assign(:user_form_data, prepare_user_form(user))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, user_form_data: to_form(changeset))}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  defp prepare_user_form(user) do
    %{
      user
      | inserted_at: format_datetime_to_view(user.inserted_at),
        updated_at: format_datetime_to_view(user.updated_at)
    }
    |> Accounts.change()
    |> to_form()
  end
end
