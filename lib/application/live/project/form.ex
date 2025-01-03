defmodule RunaWeb.Live.Project.Form do
  @moduledoc """
  Form responsible for creating and updating projects.
  """
  use RunaWeb, :live_component

  alias Runa.Languages
  alias Runa.Languages.Language
  alias Runa.Projects
  alias Runa.Projects.Project

  import RunaWeb.Components.Form
  import RunaWeb.Components.Input
  import RunaWeb.Components.Select

  @impl true
  def update(%{data: %Project{} = data} = assigns, socket) do
    action = if data.id, do: :edit, else: :new
    data = Repo.preload(data, :languages)

    socket =
      socket
      |> assign(assigns)
      |> assign(:action, action)
      |> assign_new(:form, fn -> to_form(Projects.change(data)) end)
      |> assign_new(:languages, fn ->
        {:ok, {languages, _meta}} = Languages.index()

        format_language_codes(languages)
      end)
      |> assign_new(
        :selected_languages,
        fn ->
          Enum.map(data.languages, fn %Language{wals_code: code} -> code end)
        end
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
        phx-submit="save"
        phx-target={@myself}
        aria-label="Project form"
      >
        <.input type="hidden" field={@form[:team_id]} value={@team.id} />
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
          multiple
          id="languages"
          aria-label="Project languages"
          field={@form[:languages]}
          options={@languages}
          target={@myself}
          value={@selected_languages}
        >
          <:label>Languages</:label>
        </.select>

        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  defp format_language_codes(values) when is_list(values) do
    Enum.map(values, fn
      %Language{wals_code: code, title: title} ->
        {"#{title} (#{code})", code}

      %Ecto.Changeset{data: %Language{wals_code: code}} ->
        code

      code when is_binary(code) ->
        code
    end)
  end

  defp format_language_codes(_), do: []

  @impl true
  def handle_event("clear_selection", _, socket) do
    {:noreply, assign(socket, :selected_languages, [])}
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    existing_codes =
      format_language_codes(socket.assigns.form[:languages].value)

    new_codes = Map.get(attrs, "languages", [])
    codes = existing_codes ++ new_codes

    changeset =
      Projects.change(socket.assigns.data, Map.put(attrs, "languages", codes))

    socket =
      socket
      |> assign(:selected_languages, codes)
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"project" => attrs}, socket) do
    save(socket, socket.assigns.action, attrs)
  end

  @impl true
  def handle_event(_, _, socket) do
    {:noreply, socket}
  end

  defp save(socket, :edit, attrs) do
    socket.assigns.data
    |> Projects.update(attrs)
    |> case do
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
