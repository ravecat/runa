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
    data = Repo.preload(data, :languages)

    {:ok, {languages, languages_meta}} =
      Languages.index(%{
        page: %{"size" => 50}
      })

    socket =
      socket
      |> assign(assigns)
      |> assign(:action, action)
      |> assign(:languages_meta, languages_meta)
      |> assign_new(:form, fn -> to_form(Projects.change(data)) end)
      |> assign_new(:languages, fn ->
        format_language_codes(languages)
      end)
      |> assign_new(
        :selected_languages,
        fn ->
          Enum.map(data.languages, fn %Language{wals_code: code} -> code end)
        end
      )
      |> assign_new(:displayed_languages, fn ->
        format_language_codes(data.languages)
      end)

    {:ok, socket}
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
            <input
              phx-change="search_languages"
              phx-target={@myself}
              phx-debounce
              aria-label="Search languages"
              name="query"
              type="text"
              class="flex-1 min-w-[2px] text-sm border-none p-0 m-0 bg-transparent focus:outline-none focus:ring-0"
            />
          </:selected>
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
  def handle_event(
        "load_more",
        _,
        %{assigns: %{languages_meta: %{has_next_page?: false}}} = socket
      ),
      do: {:noreply, socket}

  @impl true
  def handle_event("load_more", %{"id" => "languages"}, socket) do
    %{end_cursor: end_cursor} = socket.assigns.languages_meta

    {:ok, {languages, languages_meta}} =
      Languages.index(%{
        page: %{"size" => 50, "after" => end_cursor}
      })

    languages = socket.assigns.languages ++ format_language_codes(languages)

    socket =
      assign(socket,
        languages: languages,
        languages_meta: languages_meta
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selection", %{"option" => code}, socket) do
    existing_codes =
      format_language_codes(socket.assigns.form[:languages].value)

    new_selected_languages = existing_codes -- [code]

    new_displayed_languages =
      Enum.reject(
        socket.assigns.displayed_languages,
        &(elem(&1, 1) == code)
      )

    socket =
      socket
      |> assign(:selected_languages, new_selected_languages)
      |> assign(:displayed_languages, new_displayed_languages)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear_selection", _, socket) do
    socket =
      socket
      |> assign(:selected_languages, [])
      |> assign(:displayed_languages, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("search_languages", %{"query" => query}, socket) do
    params = %{
      filter: [%{field: :title, op: :ilike, value: query}],
      page: %{"size" => 50}
    }

    {:ok, {languages, _meta}} = Languages.index(params)

    {:noreply, assign(socket, :languages, format_language_codes(languages))}
  end

  @impl true
  def handle_event("validate", %{"project" => attrs}, socket) do
    existing_codes =
      format_language_codes(socket.assigns.form[:languages].value)

    new_codes = Map.get(attrs, "languages", [])

    language_codes = existing_codes ++ new_codes

    new_displayed_languages =
      Enum.map(new_codes, fn code ->
        {label, _} =
          Enum.find(socket.assigns.languages, fn {_, c} -> c == code end)

        {label, code}
      end)

    changeset =
      Projects.change(
        socket.assigns.data,
        Map.put(attrs, "languages", language_codes)
      )

    socket =
      socket
      |> assign(:selected_languages, language_codes)
      |> assign(
        :displayed_languages,
        new_displayed_languages ++ socket.assigns.displayed_languages
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
