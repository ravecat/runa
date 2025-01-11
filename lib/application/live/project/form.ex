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

    {:ok, {languages, languages_meta}} =
      Languages.index(%{
        page: %{"size" => 50}
      })

    socket =
      socket
      |> assign(assigns)
      |> assign(:data, data)
      |> assign(:action, action)
      |> assign(:languages_meta, languages_meta)
      |> assign_new(:form, fn -> to_form(Projects.change(data)) end)
      |> assign_new(:languages, fn ->
        Enum.map(languages, &format_language_label/1)
      end)
      |> assign_new(
        :selected_languages,
        fn ->
          Enum.map(data.languages, &format_language_code/1)
        end
      )
      |> assign_new(
        :displayed_base_language,
        fn ->
          {label, _id} = format_language_label(data.base_language)

          label
        end
      )
      |> assign_new(:displayed_languages, fn ->
        Enum.map(data.languages, &format_language_label/1)
      end)

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

  defp format_language_code(code), do: code

  defp format_language_label(value)

  defp format_language_label(%Language{wals_code: code, title: title, id: id}),
    do: {"#{title} (#{code})", id}

  defp format_language_label(%Ecto.Changeset{data: %Language{} = language}),
    do: format_language_label(language)

  defp format_language_label(code) when is_binary(code),
    do: {code, code}

  defp format_language_label(code),
    do: {to_string(code), code}

  @impl true
  def handle_event(
        "load_more",
        _,
        %{assigns: %{languages_meta: %{has_next_page?: false}}} = socket
      ),
      do: {:noreply, socket}

  @impl true
  def handle_event("load_more", %{"id" => id}, socket)
      when id in ["languages", "base_language"] do
    %{end_cursor: end_cursor} = socket.assigns.languages_meta

    {:ok, {languages, languages_meta}} =
      Languages.index(%{
        page: %{"size" => 50, "after" => end_cursor}
      })

    languages =
      socket.assigns.languages ++ Enum.map(languages, &format_language_label/1)

    socket =
      assign(socket,
        languages: languages,
        languages_meta: languages_meta
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "clear_selection",
        %{"option" => code},
        socket
      ) do
    existing_codes =
      Enum.map(
        input_value(socket.assigns.form, :languages),
        &format_language_code/1
      )

    combined_ids = existing_codes -- [code]

    changeset =
      Projects.change(
        socket.assigns.data,
        %{"languages" => combined_ids}
      )

    languages = get_field(changeset, :languages)

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
        %{"bases_language_id" => ""}
      )

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> assign(:displayed_base_language, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_options", %{"_target" => [field]} = attrs, socket) do
    params = %{
      filter: [%{field: :title, op: :ilike, value: attrs[field]}],
      page: %{"size" => 50}
    }

    {:ok, {languages, _meta}} = Languages.index(params)

    {:noreply,
     assign(
       socket,
       :languages,
       Enum.map(languages, &format_language_label/1)
     )}
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    attrs =
      case Map.get(attrs, "languages") do
        nil ->
          attrs

        languages ->
          existing_languages =
            Enum.map(
              input_value(socket.assigns.form, :languages),
              &format_language_code/1
            )

          Map.put(attrs, "languages", existing_languages ++ languages)
      end

    changeset = Projects.change(socket.assigns.data, attrs)

    selected_languages =
      Enum.map(get_field(changeset, :languages), &format_language_code/1)

    displayed_languages =
      Enum.map(get_field(changeset, :languages), &format_language_label/1)

    {base_language_label, _} =
      get_field(changeset, :base_language) |> format_language_label()

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
    |> Map.put_new("languages", [])
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
