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
    data =
      data
      |> maybe_preload(:base_language)
      |> maybe_preload(:locales)

    attrs = %{
      "base_language" => data.base_language.title,
      "locales" =>
        if(is_nil(data.id),
          do: [],
          else: Enum.map(data.languages, & &1.title)
        )
    }

    socket =
      socket
      |> assign(assigns)
      |> assign(data: data)
      |> assign(
        action: if(is_nil(data.id), do: :new, else: :edit),
        form: to_form(Project.changeset(data, attrs))
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
        <.select field={@form[:base_language]} options={@languages} target={@myself}>
          <:label>Base language</:label>
        </.select>
        <.select
          field={@form[:locales]}
          options={@languages}
          target={@myself}
          multiple
        >
          <:label>Languages</:label>
        </.select>
        <%!-- <.input type="select" field={@form[:base_language]} options={@languages}>
          <:label>Base language</:label>
        </.input>
        <.input type="select" field={@form[:locales]} options={@languages} multiple>
          <:label>Languages</:label>
        </.input> --%>

        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  @impl true
  def handle_event("clear_selection", %{"id" => id}, socket) do
    socket =
      update(socket, :form, fn %{source: changeset} ->
        changeset =
          Ecto.Changeset.put_change(changeset, String.to_atom(id), [])

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    socket =
      update(socket, :form, fn _, %{data: data} ->
        changeset =
          Project.changeset(data, attrs)

        to_form(changeset, action: :validate)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", %{"project" => attrs}, socket) do
    attrs =
      attrs
      |> put_base_language()
      |> put_locales()

    submit(socket, socket.assigns.action, attrs)
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  defp submit(socket, :edit, attrs) do
    socket.assigns.data
    |> Projects.update(attrs)
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp submit(socket, :new, attrs) do
    attrs
    |> Projects.create()
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp put_base_language(attrs) do
    Map.put(
      attrs,
      "base_language_id",
      Languages.get_by(title: attrs["base_language"]).id
    )
  end

  defp put_locales(attrs) do
    locales =
      attrs["locales"]
      |> Enum.map(fn locale ->
        %{
          "language_id" => Languages.get_by(title: locale).id
        }
      end)

    Map.put(attrs, "locales", locales)
  end
end
