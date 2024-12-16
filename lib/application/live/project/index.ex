defmodule RunaWeb.Live.Project.Index do
  @moduledoc """
  This module is responsible for the projects page.
  """
  use RunaWeb, :live_view

  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Card
  import RunaWeb.Components.Pill

  alias Runa.Accounts
  alias Runa.Teams

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
    projects = Teams.get_projects_with_statistics(team.id)

    {:ok, assign(socket, team: team, projects: projects)}
  end

  defp handle_actual_user_data(socket, _user) do
    {:ok, assign(socket, team: nil, projects: [])}
  end

  defp handle_missing_user_data(socket) do
    socket =
      socket
      |> put_flash(:error, "User not found")
      |> redirect(to: ~p"/")

    {:ok, socket}
  end
end
