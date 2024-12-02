defmodule RunaWeb.Live.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Teams.Team

  import RunaWeb.Components.Dropdown
  import RunaWeb.Components.Tab
  import RunaWeb.Components.Modal
  import RunaWeb.Components.Info
  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    if connected?(socket) do
      PubSub.subscribe("teams:#{user_id}")
    end

    {:ok, user} = Accounts.get(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:is_visible_create_team_modal, false)
      |> assign(:active_team, List.first(user.teams) || %Team{title: nil})
      |> assign(:team, %Team{})
      |> stream(:teams, user.teams)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_info({:created_team, data}, socket) do
    socket =
      socket
      |> stream_insert(:teams, data)
      |> assign(:is_visible_create_team_modal, false)

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
end
