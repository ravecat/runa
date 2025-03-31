defmodule RunaWeb.Live.Team.Show do
  @moduledoc """
  This module is responsible for the team settings page.
  """
  use RunaWeb, :live_view

  alias Runa.Contributors
  alias Runa.Teams

  on_mount(__MODULE__)

  @impl true
  def render(assigns) do
    ~H"""
    <.svelte
      name="team/show"
      props={%{team: @team, owner: @owner, members: @members, roles: @roles}}
      class="flex min-h-0"
    />
    """
  end

  def on_mount(_, _, _, socket) do
    if connected?(socket) do
      Contributors.subscribe(socket.assigns.scope)
    end

    {:cont, socket}
  end

  @impl true
  def mount(_, _, %{assigns: %{user: %{teams: [team | _]}}} = socket) do
    roles = Enum.map(Teams.get_roles(), fn {role, _} -> role end)

    socket =
      assign(socket,
        team: to_form(Teams.change(team)),
        owner: Teams.get_owner(team),
        roles: roles,
        members: Teams.get_members(team)
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"team" => attrs}, socket) do
    changeset = Teams.change(socket.assigns.team, attrs)

    {:noreply, assign(socket, team: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"team" => attrs}, socket) do
    case Teams.update(socket.assigns.scope, socket.assigns.team, attrs) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end

  @impl true
  def handle_event(
        "update_contributor:" <> id,
        %{"contributor" => attrs},
        socket
      ) do
    case Contributors.update(socket.assigns.scope, id, attrs) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Events.ContributorUpdated{data: data}, socket) do
    member = Teams.get_member(data) |> to_member_form()

    {:noreply, stream_insert(socket, :members, member)}
  end

  @spec to_member_form(Ecto.Schema.t(), map()) :: Phoenix.HTML.Form.t()
  defp to_member_form(member, attrs \\ %{}) do
    member
    |> Contributors.change(attrs)
    |> to_form(id: member.id)
  end
end
