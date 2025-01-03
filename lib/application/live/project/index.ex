defmodule RunaWeb.Live.Project.Index do
  @moduledoc """
  This module is responsible for the projects page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Card
  import RunaWeb.Components.Pill
  import RunaWeb.Components.Modal

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
      PubSub.subscribe("projects:#{team.id}")
    end

    projects = Teams.get_projects_with_statistics(team.id)

    socket =
      assign(socket,
        team: team,
        project: %Project{},
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
  def handle_event("open_project_modal", %{"id" => id}, socket) do
    case Projects.get(id) do
      {:ok, data} ->
        socket =
          socket
          |> assign(:project, data)
          |> assign(:is_visible_project_modal, true)

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("open_project_modal", _, socket) do
    socket =
      assign(socket, :is_visible_project_modal, true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("open_delete_project_modal", %{"id" => id}, socket) do
    case Projects.get(id) do
      {:ok, data} ->
        socket =
          socket
          |> assign(:project, data)
          |> assign(:is_visible_delete_project_modal, true)

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("close_project_modal", _, socket) do
    socket =
      assign(socket, :is_visible_project_modal, false)
      |> assign(:project, %Project{})

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete_project", _, socket) do
    case Projects.delete(socket.assigns.project) do
      {:ok, _} ->
        socket =
          socket
          |> stream_delete(:projects, socket.assigns.project)
          |> assign(:project, %Project{})
          |> assign(:is_visible_delete_project_modal, false)

        {:noreply, socket}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("duplicate_project", %{"id" => id}, socket) do
    with {:ok, data} <- Projects.get(id),
         {:ok, new_data} <-
           Projects.duplicate(data, %{
             name: "#{data.name} (copy)",
             languages: fn changeset, assoc_name, languages ->
               put_assoc(changeset, assoc_name, languages)
             end
           }) do
      updated_data =
        Teams.get_projects_with_statistics(socket.assigns.team.id)
        |> Enum.find(&(&1.id == new_data.id))

      socket =
        stream_insert(socket, :projects, updated_data)

      {:noreply, socket}
    else
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:updated_project, %Project{} = data}, socket) do
    updated_data =
      Teams.get_projects_with_statistics(socket.assigns.team.id)
      |> Enum.find(&(&1.id == data.id))

    socket =
      socket
      |> stream_delete(:projects, data)
      |> stream_insert(:projects, updated_data)
      |> assign(:project, %Project{})
      |> assign(:is_visible_project_modal, false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:created_project, %Project{} = data}, socket) do
    updated_data =
      Teams.get_projects_with_statistics(socket.assigns.team.id)
      |> Enum.find(&(&1.id == data.id))

    socket =
      socket
      |> stream_insert(:projects, updated_data)
      |> assign(:project, %Project{})
      |> assign(:is_visible_project_modal, false)

    {:noreply, socket}
  end

  def handle_info(_, socket), do: {:noreply, socket}
end
