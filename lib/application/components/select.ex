defmodule RunaWeb.Components.Select do
  @moduledoc """
   A select component.
  """

  use RunaWeb, :component

  import RunaWeb.Components.Label
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Pill

  attr :id, :string, required: true

  attr :field, Phoenix.HTML.FormField,
    doc:
      "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []

  attr :value, :any,
    doc: "the values to pass to Phoenix.HTML.Form.options_for_select/2"

  attr :options, :list,
    doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2",
    default: []

  attr :multiple, :boolean,
    default: false,
    doc: "the multiple flag for select inputs"

  attr :show, :boolean, default: false

  attr :searchable, :boolean,
    default: false,
    doc: "the options required for displaying a search input"

  attr :class, :string, default: ""
  attr :name, :any
  attr :rest, :global

  attr :target, Phoenix.LiveComponent.CID,
    doc:
      "a target component required for handling events from the select component",
    default: nil

  slot :label
  slot :selected

  def select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(
      :errors,
      Enum.map(field.errors, &translate_error(&1))
    )
    |> assign_new(:name, fn ->
      if assigns.multiple,
        do: field.name <> "[]",
        else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> select()
  end

  def select(assigns) do
    ~H"""
    <div
      class="relative gap-2"
      phx-feedback-for={@name}
      phx-click-away={hide_options(@id)}
      phx-click={toggle_options(@id)}
    >
      <.label :if={@label != []} for={@id}>
        {render_slot(@label)}
      </.label>
      <div
        role="combobox"
        aria-controls={@id}
        aria-orientation="vertical"
        class="w-full border rounded focus:ring-0 sm:text-sm sm:leading-6 min-h-10 px-3 py-2 flex justify-between items-center gap-1"
      >
        <div
          class="flex flex-wrap gap-1 flex-grow self-stretch"
          aria-live="polite"
          aria-label={
            if(@multiple, do: "Selected options", else: "Selected option")
          }
        >
          <%= unless @selected != [] do %>
            <.pill
              :for={label <- @value}
              :if={@multiple}
              class="border bg-accent cursor-default"
            >
              {label}
              <.icon
                icon="x-mark"
                class="cursor-pointer"
                aria-label={"Clear #{label} selection"}
                role="button"
                phx-target={@target}
                phx-click={JS.push("clear_selection", value: %{label: label})}
              />
            </.pill>
            <span :if={!@multiple} class="truncate flex-grow">
              {@value}
            </span>
          <% else %>
            {render_slot(@selected, @value)}
          <% end %>
          <input
            :if={@searchable}
            class="flex-1 min-w-[2px] text-sm border-none p-0 m-0 bg-transparent focus:outline-none focus:ring-0"
            phx-change={JS.push("search_options")}
            phx-target={@target}
            phx-debounce
            aria-label="Search options"
            name={@id}
            type="text"
          />
        </div>
        <.icon
          icon="x-mark"
          class="cursor-pointer"
          aria-label="Clear selection"
          role="button"
          phx-target={@target}
          phx-click={JS.push("clear_selection", value: %{id: @id})}
        />
        <.icon
          icon="shevron-bottom"
          id={"#{@id}-shevron"}
          aria-label="Toggle options"
          role="button"
          class="cursor-pointer transition-transform duration-300"
        />
      </div>
      <select
        id={@id}
        name={@name}
        aria-hidden="true"
        role="listbox"
        phx-hook="infiniteScroll"
        phx-target={@target}
        size={max(1, length(@options))}
        class={
          classes([
            "hidden border top-full absolute mt-1 p-0 rounded bg-background w-full dark:bg-background h-fit max-h-[18.75rem] overflow-auto z-50 shadow-sm transition hover:shadow focus:ring-0 sm:text-sm",
            "[&>option]:flex [&>option]:items-center [&>option]:p-2 [&>option]:gap-[.25rem] [&>option]:truncate [&>option]:cursor-pointer [&>option:hover]:bg-background-hover",
            @class
          ])
        }
        multiple={@multiple}
        {@rest}
      >
        <%= if Enum.empty?(@options) do %>
          <option disabled>No options available</option>
        <% else %>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        <% end %>
      </select>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  defp toggle_options(js \\ %JS{}, id) when is_binary(id) do
    JS.toggle_class(
      js,
      "hidden",
      to: "##{id}"
    )
    |> JS.toggle_attribute({"aria-hidden", "true", "false"},
      to: "##{id}"
    )
    |> JS.toggle_class("rotate-180",
      to: "##{id}-shevron"
    )
  end

  defp hide_options(js \\ %JS{}, id) do
    JS.add_class(
      js,
      "hidden",
      to: "##{id}"
    )
    |> JS.remove_class("rotate-180",
      to: "##{id}-shevron"
    )
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(
        RunaWeb.Gettext,
        "errors",
        msg,
        msg,
        count,
        opts
      )
    else
      Gettext.dgettext(RunaWeb.Gettext, "errors", msg, opts)
    end
  end

  def translate_errors(errors, field)
      when is_list(errors) do
    for {^field, {msg, opts}} <- errors,
        do: translate_error({msg, opts})
  end

  @doc """
  Generates a generic error message.
  """
  slot(:inner_block, required: true)

  def error(assigns) do
    ~H"""
    <p class="mt-3 flex gap-3 text-sm leading-6 text-error-600 phx-no-feedback:hidden">
      <.icon icon="exclamation-circle" class="mt-0.5 h-5 w-5 flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end
end
