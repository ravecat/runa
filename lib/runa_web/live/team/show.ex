defmodule RunaWeb.Live.Team.Show do
  @moduledoc """
  This module is responsible for the team settings page.
  """
  use RunaWeb, :live_view

  alias Runa.Contributors
  alias Runa.Invitations
  alias Runa.Teams

  on_mount(__MODULE__)

  @impl true
  def render(assigns) do
    ~H"""
    <.svelte
      name="team/show"
      props={
        %{
          team: @team,
          owner: @owner,
          current_user: @current_user,
          members: @members,
          roles: @roles,
          invite: @invite
        }
      }
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
        current_user: socket.assigns.user,
        members: Teams.get_members(team),
        invite: to_invite_form(Invitations.to_invite_changeset())
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"team" => attrs}, socket) do
    changeset = Teams.change(socket.assigns.team.data, attrs)

    {:noreply, assign(socket, team: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"team" => attrs}, socket) do
    case Teams.update(socket.assigns.scope, socket.assigns.team.data, attrs) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, team: to_form(changeset))}

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
  def handle_event("delete_contributor:" <> id, _, socket) do
    case Contributors.delete(socket.assigns.scope, id) do
      {:ok, _} -> {:noreply, socket}
      {:error, _} -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate_contributors", attrs, socket) do
    changeset = Invitations.to_invite_changeset(attrs)
    form = to_invite_form(changeset, action: :validate)

    {:reply, form, assign(socket, invite: form)}
  end

  @impl true
  def handle_event("invite_contributors", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Events.ContributorUpdated{data: data}, socket) do
    members =
      Enum.map(socket.assigns.members, fn member ->
        if member.id == data.id do
          data
        else
          member
        end
      end)

    {:noreply, assign(socket, :members, members)}
  end

  @impl true
  def handle_info(%Events.ContributorDeleted{data: data}, socket) do
    members =
      Enum.filter(socket.assigns.members, fn member -> member.id != data.id end)

    {:noreply, assign(socket, :members, members)}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp to_invite_form(changeset, opts \\ []) do
    to_form(changeset, Keyword.merge([as: :invite], opts))
  end
end
