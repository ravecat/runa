defmodule RunaWeb.Live.Project.Show do
  @moduledoc """
  This module is responsible for the projects page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Card

  alias Runa.Accounts
  alias Runa.Projects
  alias Runa.Projects.Project
  alias Runa.Teams

  @impl true
  def mount(_, %{"user_id" => user_id}, socket),
    do: handle_user_data(user_id, socket)

  def mount(_, _, socket), do: {:ok, redirect(socket, to: ~p"/")}

  defp handle_user_data(user_id, socket) do
    case Accounts.get(user_id) do
      {:ok, user} -> handle_actual_user_data(socket, user)
      {:error, %Ecto.NoResultsError{}} -> handle_missing_user_data(socket)
      _ -> {:ok, redirect(socket, to: ~p"/")}
    end
  end

  defp handle_actual_user_data(socket, %{teams: [team | _]}) do
    if connected?(socket) do
      Projects.subscribe(team)
    end

    projects = Teams.get_projects_with_statistics(team.id)

    socket =
      assign(socket,
        team: team,
        project: %Project{},
        project_id: nil,
        is_visible_project_modal: false,
        is_visible_delete_project_modal: false
      )
      |> stream(:projects, projects)

    {:ok, socket}
  end

  defp handle_actual_user_data(socket, _user) do
    socket =
      assign(
        socket,
        team: nil,
        is_visible_project_modal: false
      )
      |> stream(:projects, [])

    {:ok, socket}
  end

  defp handle_missing_user_data(socket) do
    socket =
      socket
      |> put_flash(:error, "User not found")
      |> redirect(to: ~p"/")

    {:ok, socket}
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
