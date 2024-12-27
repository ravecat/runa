defmodule RunaWeb.Live.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Teams
  alias Runa.Teams.Team

  import RunaWeb.Components.Dropdown
  import RunaWeb.Components.Pill
  import RunaWeb.Components.Modal
  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    handle_user_data(user_id, socket)
  end

  defp handle_user_data(user_id, socket) do
    case Accounts.get(user_id) do
      {:ok, user} ->
        if connected?(socket) do
          PubSub.subscribe("teams:#{user.id}")
          PubSub.subscribe("accounts:#{user.id}")
        end

        handle_actual_user_data(socket, user)

      {:error, %Ecto.NoResultsError{}} ->
        handle_missing_user_data(socket)

      _ ->
        {:ok, redirect(socket, to: ~p"/")}
    end
  end

  defp handle_actual_user_data(socket, %{teams: [team | _]} = user) do
    role = Teams.get_role(user.id, team.id)

    teams =
      Enum.map(user.teams, fn team ->
        Map.put(team, :role, Teams.get_role(user.id, team.id))
      end)

    socket =
      assign(socket,
        user: user,
        is_visible_create_team_modal: false,
        team: team,
        role: role,
        team_form_data: %Team{},
        teams: teams
      )
      |> stream(:teams, teams)

    {:ok, socket, layout: false}
  end

  defp handle_actual_user_data(socket, user) do
    socket =
      assign(
        socket,
        team: nil,
        user: user,
        team_form_data: %Team{},
        is_visible_create_team_modal: false
      )
      |> stream(:teams, [])

    {:ok, socket, layout: false}
  end

  defp handle_missing_user_data(socket) do
    socket =
      socket
      |> put_flash(:error, "User not found")
      |> redirect(to: ~p"/")

    {:ok, socket}
  end

  @impl true
  def handle_info({:created_team, data}, socket) do
    data =
      Map.put(data, :role, Teams.get_role(socket.assigns.user.id, data.id))

    socket =
      socket
      |> stream_insert(:teams, data)
      |> assign(:is_visible_create_team_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:updated_account, data}, socket) do
    socket =
      assign(socket, :user, data)

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
