defmodule RunaWeb.Components.Button do
  @moduledoc """
  Renders a button.

  ## Examples
    <.button>Send!</.button>
    <.button phx-click="go" class="ml-2">Send!</.button>
  """
  use RunaWeb, :component

  import RunaWeb.Components.Spinner

  attr :type, :string, default: "button"
  attr :square, :boolean, default: false

  attr :variant, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "warning", "danger", "ghost"]

  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={
        classes([
          {:"group border rounded flex items-center justify-center px-3 h-[2rem] min-w-[5rem] text-sm font-medium disabled:opacity-50 phx-submit-loading:opacity-75",
           true},
          {:"bg-primary hover:bg-primary-400", match?("primary", @variant)},
          {:"bg-secondary hover:bg-secondary-400", match?("secondary", @variant)},
          {:"bg-accent hover:bg-accent-400", match?("accent", @variant)},
          {:"bg-warning hover:bg-warning-400", match?("warning", @variant)},
          {:"bg-danger hover:bg-danger-400", match?("danger", @variant)},
          {:"bg-background hover:bg-background-hover", match?("ghost", @variant)},
          {:"#{@class}", not match?("", @class)},
          {:"aspect-square min-w-0 p-0", @square}
        ])
      }
      {@rest}
    >
      <.spinner class={
        classes(
          "group-[.phx-submit-loading]:block hidden text-background": true,
          "text-primary": match?("ghost", @variant)
        )
      } />
      <span class={
        classes(
          "group-[.phx-submit-loading]:hidden flex items-center justify-center align-middle truncate leading-none gap-2 text-background":
            true,
          "text-primary": match?("ghost", @variant)
        )
      }>
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end
end
