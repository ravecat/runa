defmodule RunaWeb.Live.Profile.Show do
  @moduledoc """
  This module is responsible for the profile page and user data management.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Services.Avatar
  alias Runa.Tokens

  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Input
  import RunaWeb.Components.Form
  import RunaWeb.Components.Panel
  import RunaWeb.Formatters

  @impl true
  def mount(_, _, %{assigns: %{user: user}} = socket) do
    if connected?(socket) do
      Tokens.subscribe(user.id)
    end

    socket = assign(socket, :profile, to_user_form(user))

    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => attrs}, socket) do
    {:noreply,
     assign(socket,
       profile: to_user_form(socket.assigns.user, attrs, action: :validate)
     )}
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

        socket = assign(socket, user: user, profile: to_user_form(user))

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, profile: to_user_form(changeset))}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @spec to_user_form(Ecto.Schema.t(), map(), keyword()) :: Phoenix.HTML.Form.t()
  defp to_user_form(user, attrs \\ %{}, opts \\ []) do
    user
    |> Accounts.change(attrs)
    |> to_form(opts)
  end
end
