defmodule Runa.Teams.Notifier do
  use GenServer

  alias Runa.Events
  alias Runa.Mailer
  import Runa.Teams.Email
  alias Runa.Teams.Invitations

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
      invitation |> invite_to_team() |> Mailer.deliver()
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
