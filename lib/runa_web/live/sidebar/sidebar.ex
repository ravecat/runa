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

  on_mount RunaWeb.Scope
  on_mount __MODULE__

  def on_mount(_, _, %{"current_uri" => current_uri}, socket) do
    if connected?(socket) do
      Teams.subscribe(socket.assigns.scope)
      Accounts.subscribe(socket.assigns.scope)
    end

    socket =
      assign(socket,
        current_uri: current_uri,
        team: %Team{},
        user: socket.assigns.scope.current_user
      )

    {:cont, socket}
  end

  @impl true
  def mount(_, _, %{assigns: %{user: %{teams: [team | _]} = user}} = socket) do
    role = Contributors.get_role(user.id, team.id)
    teams = Teams.get_user_teams_with_role(user.id)

    socket =
      assign(socket, active_team: team, active_role: role)
      |> stream_configure(:teams, dom_id: &"#{elem(&1, 0).id}")
      |> stream(:teams, teams)

    {:ok, socket, layout: false}
  end

  @impl true
  def mount(_, _, socket) do
    socket =
      assign(socket, active_team: nil, active_role: nil) |> stream(:teams, [])

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_info(%Events.TeamCreated{data: data}, socket) do
    socket =
      stream_insert(
        socket,
        :teams,
        {data, Contributors.get_role(socket.assigns.user.id, data.id)}
      )
      |> assign(live_action: nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Events.AccountUpdated{data: data}, socket) do
    socket = assign(socket, :user, data)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  @impl true
  def handle_event("create_team", _, socket) do
    {:noreply, assign(socket, live_action: :create_team)}
  end

  @impl true
  def handle_event("close_team_modal", _, socket) do
    {:noreply, assign(socket, live_action: nil)}
  end
end
