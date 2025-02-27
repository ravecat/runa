defmodule RunaWeb.Live.Project.Show do
  @moduledoc """
  This module is responsible for the projects page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Card
  import RunaWeb.Components.Navigation
  import RunaWeb.Components.Link
  import RunaWeb.Components.Button

  alias Runa.Projects
  alias Runa.Teams

  on_mount RunaWeb.SaveRequestUri

  @impl true
  def mount(%{"project_id" => project_id}, _session, socket) do
    {:ok, team} = Teams.get_team_by_project_id(project_id)
    {:ok, project} = Projects.get(project_id)

    socket =
      assign(socket, project_id: project_id, team_id: team.id, project: project)

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"section" => section}, _, socket)
      when section in ["settings", "files", "translations"] do
    socket = assign(socket, section: section)

    {:noreply, socket}
  end

  @impl true
  def handle_params(%{"project_id" => project_id}, _, socket) do
    {:noreply,
     push_patch(socket, to: ~p"/projects/#{project_id}?section=files")}
  end

  @impl true
  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
