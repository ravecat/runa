defmodule RunaWeb.Live.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Contributors
  alias Runa.Teams
  alias Runa.Teams.Team

  import RunaWeb.Components.Dropdown
  import RunaWeb.Components.Modal
  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon

  on_mount RunaWeb.HandleUserData

  @impl true
  def mount(
        _,
        %{"current_uri" => current_uri},
        %{assigns: %{user: %{teams: [team | _]} = user}} = socket
      ) do
    subscribe(socket)

    role = get_role(user.id, team.id)

    teams = Teams.get_user_teams_with_role(user.id)

    socket =
      assign(socket,
        user: user,
        team: team,
        role: role,
        current_uri: current_uri,
        team_form_data: %Team{},
        is_visible_create_team_modal: false
      )
      |> stream_configure(:teams, dom_id: &"#{elem(&1, 0).id}")
      |> stream(:teams, teams)

    {:ok, socket, layout: false}
  end

  @impl true
  def mount(
        _,
        %{"current_uri" => current_uri},
        %{assigns: %{user: user}} = socket
      ) do
    subscribe(socket)

    socket =
      assign(socket,
        team: nil,
        user: user,
        role: nil,
        team_form_data: %Team{},
        current_uri: current_uri,
        is_visible_create_team_modal: false
      )
      |> stream(:teams, [])

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_info({:team_created, data}, socket) do
    socket =
      socket
      |> stream_insert(
        :teams,
        {data, get_role(socket.assigns.user.id, data.id)}
      )
      |> assign(:is_visible_create_team_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:account_updated, data}, socket) do
    socket = assign(socket, :user, data)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  @impl true
  def handle_event("open_create_team_modal", _, socket) do
    {:noreply, assign(socket, :is_visible_create_team_modal, true)}
  end

  @impl true
  def handle_event("close_create_team_modal", _, socket) do
    {:noreply, assign(socket, :is_visible_create_team_modal, false)}
  end

  defp get_role(user_id, team_id) do
    Contributors.get_by(user_id: user_id, team_id: team_id).role
  end

  defp subscribe(%{assigns: %{user: user}} = socket) do
    if connected?(socket) do
      Teams.subscribe()
      Accounts.subscribe(user.id)
    end
  end
end
