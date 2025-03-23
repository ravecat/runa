defmodule RunaWeb.Live.Project.Index do
  @moduledoc """
  This module is responsible for the projects page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Button
  import RunaWeb.Components.Modal

  alias Runa.Projects
  alias Runa.Projects.Project
  alias Runa.Teams

  on_mount __MODULE__

  def on_mount(_, _, _, socket) do
    if connected?(socket) do
      Projects.subscribe(socket.assigns.scope)
    end

    {:cont, socket}
  end

  @impl true
  def mount(_, _, %{assigns: %{user: %{teams: [team | _]}}} = socket) do
    projects = Teams.get_projects_with_statistics(team.id)

    socket =
      assign(socket, team_id: team.id, projects: projects)
      |> stream(:projects, projects)

    {:ok, socket}
  end

  def mount(_, _, socket) do
    socket = assign(socket, team_id: nil, projects: []) |> stream(:projects, [])

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _) do
    assign(socket, project: build_project(socket.assigns.team_id))
  end

  defp apply_action(socket, action, %{"id" => id})
       when action in [:edit, :delete] do
    {:ok, data} = Projects.get(socket.assigns.scope, id)

    assign(socket, project: data)
  end

  defp apply_action(socket, _, _) do
    socket
  end

  @impl true
  def handle_event("delete_project", %{"id" => id}, socket) do
    case Projects.delete(socket.assigns.scope, id) do
      {:ok, data} ->
        socket =
          stream_delete(socket, :projects, data)
          |> push_patch(to: ~p"/projects")

        {:noreply, socket}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("duplicate_project", %{"id" => id}, socket) do
    with {:ok, data} <- Projects.get(socket.assigns.scope, id),
         {:ok, new_data} <-
           Projects.duplicate(data, %{
             name: "#{data.name} (copy)",
             languages: fn changeset, assoc_name, languages ->
               put_assoc(changeset, assoc_name, languages)
             end
           }) do
      updated_data =
        Teams.get_projects_with_statistics(socket.assigns.team_id)
        |> Enum.find(&(&1.id == new_data.id))

      socket = stream_insert(socket, :projects, updated_data)

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Events.ProjectUpdated{data: data}, socket) do
    updated_data =
      Teams.get_projects_with_statistics(socket.assigns.team_id)
      |> Enum.find(&(&1.id == data.id))

    socket =
      socket
      |> stream_delete(:projects, data)
      |> stream_insert(:projects, updated_data)
      |> push_patch(to: ~p"/projects")

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Events.ProjectCreated{data: data}, socket) do
    updated_data =
      Teams.get_projects_with_statistics(socket.assigns.team_id)
      |> Enum.find(&(&1.id == data.id))

    socket =
      stream_insert(socket, :projects, updated_data)
      |> push_patch(to: ~p"/projects")

    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  defp build_project(team_id), do: %Project{team_id: team_id}
end
