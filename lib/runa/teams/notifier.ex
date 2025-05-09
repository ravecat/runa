defmodule Runa.Teams.Notifier do
  @moduledoc """
  GenServer for handling team invitation notifications.
  """
  use GenServer

  alias Runa.Events
  alias Runa.Teams.Invitations

  import Runa.Teams.Email

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Invitations.subscribe()
    {:ok, %{}}
  end

  @impl true
  def handle_info(%Events.InvitationCreated{data: invitation}, socket) do
    Task.Supervisor.start_child(Runa.AsyncEmailSupervisor, fn ->
      deliver_invitation_to_team(invitation)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
