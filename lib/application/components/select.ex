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

  def select(%{multiple: true} = assigns) do
    ~H"""
    <div class="relative" phx-feedback-for={@name}>
      <.label :if={@label != []} for={@id}>{render_slot(@label)}</.label>
      <div
        phx-click={toggle_options(@id)}
        phx-click-away={hide_options(@id)}
        role="combobox"
        aria-controls={@id}
        aria-orientation="vertical"
        class="border rounded focus:ring-0 sm:text-sm sm:leading-6 mt-2 min-h-10 px-3 py-2 flex justify-between items-center gap-1"
      >
        <div
          class="flex flex-wrap gap-1 flex-grow"
          aria-live="polite"
          aria-label="Selected options"
        >
          <%= if @selected != [] do %>
            {render_slot(@selected, @value)}
          <% else %>
            <.pill :for={label <- @value} class="border bg-accent cursor-default">
              {label}
            </.pill>
          <% end %>
        </div>
        <div class="flex items-center gap-1 flex-shrink-0">
          <.icon
            icon="x-mark"
            class="cursor-pointer"
            aria-label="Clear selection"
            role="button"
            phx-target={@target}
            phx-click="clear_selection"
          />
          <.icon
            icon="shevron-right"
            aria-label="Toggle options"
            role="button"
            class="cursor-pointer rotate-90 transition-transform duration-300 group-open:rotate-[270deg]"
          />
        </div>
      </div>
      <select
        id={@id}
        name={@name}
        aria-hidden="true"
        role="listbox"
        class={
          merge([
            "hidden absolute mt-1 p-0 rounded border bg-background w-full dark:bg-background h-[300px] z-50 shadow-sm focus:border-secondary focus:ring-0 sm:text-sm",
            "[&>option]:flex [&>option]:items-center [&>option]:p-2 [&>option]:gap-[.25rem] [&>option]:truncate [&>option]:cursor-pointer [&>option:hover]:bg-background-hover",
            @class
          ])
          |> to_string
        }
        multiple={@multiple}
        {@rest}
      >
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
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
    |> JS.toggle_attribute({"aria-hidden", "true", "false"}, to: "##{id}")
  end

  defp hide_options(js \\ %JS{}, id) do
    JS.add_class(
      js,
      "hidden",
      to: "##{id}"
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
