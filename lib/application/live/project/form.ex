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
  import RunaWeb.Components.Pill
  import RunaWeb.Components.Icon

  @impl true
  def update(%{data: %Project{} = data} = assigns, socket) do
    action = if data.id, do: :edit, else: :new
    data = Repo.preload(data, [:languages, :base_language])

    {:ok, {languages, _}} = Languages.index()

    socket =
      socket
      |> assign(assigns)
      |> assign(:action, action)
      |> assign_new(:form, fn -> to_form(Projects.change(data)) end)
      |> assign(:languages, Enum.map(languages, &format_language_label/1))
      |> assign(
        :selected_languages,
        Enum.map(data.languages, &format_language_code/1)
      )
      |> assign_new(
        :displayed_base_language,
        fn ->
          {label, _id} = format_language_label(data.base_language)

          label
        end
      )
      |> assign(
        :displayed_languages,
        Enum.map(data.languages, &format_language_label/1)
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
        <.input type="hidden" field={@form[:team_id]} value={to_string(@team.id)} />
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
          id="base_language"
          field={@form[:base_language_id]}
          options={@languages}
          target={@myself}
          searchable
        >
          <:label>Base language</:label>
          <:selected>
            {@displayed_base_language}
          </:selected>
        </.select>
        <.select
          id="languages"
          field={@form[:languages]}
          options={@languages}
          target={@myself}
          value={@selected_languages}
          searchable
          multiple
        >
          <:label>Languages</:label>
          <:selected>
            <.pill
              :for={{label, code} <- @displayed_languages}
              class="border bg-accent cursor-default"
            >
              {label}
              <.icon
                icon="x-mark"
                class="cursor-pointer"
                aria-label={"Clear #{code} selection"}
                role="button"
                phx-target={@myself}
                phx-click="clear_selection"
                phx-value-option={code}
              />
            </.pill>
          </:selected>
        </.select>

        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  defp format_language_code(%Language{id: id}), do: to_string(id)

  defp format_language_code(%Ecto.Changeset{data: %Language{id: id}}),
    do: to_string(id)

  defp format_language_code(code), do: to_string(code)

  defp format_language_label(%Language{wals_code: code, title: title, id: id}),
    do: {"#{title} (#{code})", to_string(id)}

  defp format_language_label(%Ecto.Changeset{data: %Language{} = language}),
    do: format_language_label(language)

  defp format_language_label(code),
    do: {to_string(code), to_string(code)}

  @impl true
  def handle_event(
        "clear_selection",
        %{"option" => code},
        socket
      ) do
    existing_codes =
      Enum.map(
        Form.input_value(socket.assigns.form, :languages),
        &format_language_code/1
      )

    combined_ids = existing_codes -- [code]

    changeset =
      Projects.change(
        socket.assigns.data,
        %{"languages" => combined_ids}
      )

    languages = Changeset.get_field(changeset, :languages)

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> assign(
        :selected_languages,
        Enum.map(languages, &format_language_code/1)
      )
      |> assign(
        :displayed_languages,
        Enum.map(languages, &format_language_label/1)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selection", %{"id" => "languages"}, socket) do
    changeset =
      Projects.change(
        socket.assigns.data,
        %{"languages" => []}
      )

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> assign(:selected_languages, [])
      |> assign(:displayed_languages, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selection", %{"id" => "base_language"}, socket) do
    changeset =
      Projects.change(
        socket.assigns.data,
        %{"base_language_id" => ""}
      )

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> assign(:displayed_base_language, "")

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    languages =
      Enum.map(
        Form.input_value(socket.assigns.form, :languages),
        &format_language_code/1
      ) ++ Map.get(attrs, "languages", [])

    attrs = Map.put(attrs, "languages", languages)

    changeset = Projects.change(socket.assigns.data, attrs)

    selected_languages =
      Enum.map(
        Changeset.get_field(changeset, :languages),
        &format_language_code/1
      )

    displayed_languages =
      Enum.map(
        Changeset.get_field(changeset, :languages),
        &format_language_label/1
      )

    {base_language_label, _} =
      Changeset.get_field(changeset, :base_language) |> format_language_label()

    socket =
      socket
      |> assign(:displayed_base_language, base_language_label)
      |> assign(:selected_languages, selected_languages)
      |> assign(
        :displayed_languages,
        displayed_languages
      )
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
    attrs = Map.put_new(attrs, "languages", [])

    socket.assigns.data
    |> Projects.update(attrs)
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save(socket, :new, attrs) do
    attrs
    |> Map.put_new("languages", [])
    |> Projects.create()
    |> case do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
