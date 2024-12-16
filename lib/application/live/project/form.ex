defmodule RunaWeb.Live.Project.Form do
  use RunaWeb, :live_component

  alias Runa.Projects
  alias Runa.Projects.Project

  import RunaWeb.Components.Form
  import RunaWeb.Components.Input

  @impl true
  def update(%{data: %Project{} = data} = assigns, socket) do
    action = if data.id, do: :edit, else: :new

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:action, action)
     |> assign_new(:form, fn -> to_form(Projects.change(data)) end)}
  end

  slot :actions, doc: "the slot for form actions, such as a submit button"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.custom_form
        id={@id}
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        aria-label="Project form"
      >
        <.input type="text" aria-label="Project name" field={@form[:name]}>
          <:label>Name</:label>
        </.input>
        <.input
          type="textarea"
          aria-label="Project description"
          field={@form[:description]}
        >
          <:label>Description</:label>
        </.input>

        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    changeset =
      Projects.change(socket.assigns.data, attrs)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"project" => attrs}, socket) do
    save(socket, socket.assigns.action, attrs)
  end

  defp save(socket, :edit, attrs) do
    case Projects.update(socket.assigns.data, attrs) do
      {:ok, data} ->
        PubSub.broadcast(
          "projects:#{socket.assigns.team.id}",
          {:updated_project, data}
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save(socket, :new, attrs) do
    attrs = Map.put(attrs, "team_id", socket.assigns.team.id)

    attrs
    |> Projects.create()
    |> case do
      {:ok, data} ->
        PubSub.broadcast(
          "projects:#{socket.assigns.team.id}",
          {:created_project, data}
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
