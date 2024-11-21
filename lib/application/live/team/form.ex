defmodule RunaWeb.TeamLive.Form do
  use RunaWeb, :live_component
  use RunaWeb, :components

  alias Runa.Teams
  alias Runa.Teams.Team

  @impl true
  def update(%{data: %Team{} = data} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Teams.change(data))
     end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.custom_form
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input type="text" field={@form[:title]} label="Title" />
        <:actions>
          <.button type="submit">
            Create
          </.button>
        </:actions>
      </.custom_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"team" => attrs}, socket) do
    changeset =
      Teams.change(socket.assigns.data, attrs)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"team" => attrs}, socket) do
    save(socket, socket.assigns.action, attrs)
  end

  defp save(socket, :new, attrs) do
    case Teams.create(attrs, socket.assigns.user) do
      {:ok, data} ->
        PubSub.broadcast("teams:#{socket.assigns.user.id}", {:created_team, data})

        {:noreply, put_flash(socket, :info, "Team created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end
end
