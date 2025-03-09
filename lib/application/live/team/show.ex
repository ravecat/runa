defmodule RunaWeb.Live.Team.Show do
  @moduledoc """
  This module is responsible for the team settings page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Panel
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Form
  import RunaWeb.Components.Input
  import RunaWeb.Formatters
  import RunaWeb.Components.Table

  alias Runa.Contributors
  alias Runa.Teams

  on_mount __MODULE__

  @impl true
  def mount(_, _, %{assigns: %{user: %{teams: [team | _]}}} = socket) do
    socket =
      assign(socket,
        team: team,
        form: to_form(Teams.change(team)),
        owner: Teams.get_owner(team),
        roles: Enum.map(Teams.get_roles(), fn {role, _} -> {role, role} end)
      )
      |> stream(:members, Teams.get_members(team))

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"team" => attrs}, socket) do
    changeset = Teams.change(socket.assigns.team, attrs)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"team" => attrs}, socket) do
    case Teams.update(socket.assigns.team, attrs) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end

  @impl true
  def handle_event("update_role:" <> id, %{"role" => role}, socket) do
    dbg(Contributors.update(id, %{role: role}))

    case Contributors.update(id, %{role: role}) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  def on_mount(_, _, _, socket) do
    if connected?(socket) do
      Contributors.subscribe()
    end

    {:cont, socket}
  end
end
