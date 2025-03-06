defmodule RunaWeb.Live.Project.Form do
  @moduledoc """
  Form responsible for creating and updating projects.
  """
  use RunaWeb, :live_component

  alias Runa.Languages
  alias Runa.Projects
  alias Runa.Projects.Project

  import RunaWeb.Components.Form
  import RunaWeb.Components.Input
  import RunaWeb.Components.Select

  @impl true
  def mount(socket) do
    {:ok, {languages, _}} = Languages.index()

    {:ok, assign(socket, languages: Enum.map(languages, &{&1.title, &1.title}))}
  end

  @impl true
  def update(%{data: %Project{} = data} = assigns, socket) do
    data = data |> maybe_preload(:base_language) |> maybe_preload(:languages)

    attrs = %{
      "base_language_title" =>
        if(is_nil(data.id), do: "", else: data.base_language.title),
      "language_titles" =>
        if(is_nil(data.id), do: [], else: Enum.map(data.languages, & &1.title))
    }

    socket =
      socket
      |> assign(assigns)
      |> assign(data: data)
      |> assign(
        action: if(is_nil(data.id), do: :new, else: :edit),
        form: to_form(Project.form_changeset(data, attrs))
      )

    {:ok, socket}
  end

  slot(:actions, doc: "the slot for form actions, such as a submit button")

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.custom_form
        id={@id}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        phx-target={@myself}
        aria-label="Project form"
      >
        <.input type="hidden" field={@form[:team_id]} value={@team_id} />
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
        <.select
          field={@form[:base_language_title]}
          options={@languages}
          target={@myself}
        >
          <:label>Base language</:label>
        </.select>
        <.select
          field={@form[:language_titles]}
          options={@languages}
          target={@myself}
          multiple
        >
          <:label>Languages</:label>
        </.select>

        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    socket =
      update(socket, :form, fn _, %{data: data} ->
        changeset = Project.form_changeset(data, attrs)

        to_form(changeset, action: :validate)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"project" => attrs}, socket) do
    submit(socket, socket.assigns.action, attrs)
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  defp submit(socket, :edit, attrs) do
    socket.assigns.data
    |> Projects.update(attrs, with: &Project.form_changeset/2)
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp submit(socket, :new, attrs) do
    attrs
    |> Projects.create(with: &Project.form_changeset/2)
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
