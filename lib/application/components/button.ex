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
          "group border buttonable disabled:opacity-50 phx-submit-loading:opacity-75",
          [
            primary: match?("primary", @variant),
            secondary: match?("secondary", @variant),
            accent: match?("accent", @variant),
            warning: match?("warning", @variant),
            danger: match?("danger", @variant),
            ghost: match?("ghost", @variant),
            "aspect-square min-w-0 p-0": @square
          ],
          @class
        ])
      }
      {@rest}
    >
      <.spinner class={
        classes([
          "group-[.phx-submit-loading]:block hidden",
          ["text-primary": match?("ghost", @variant)]
        ])
      } />
      <span class={
        classes([
          "group-[.phx-submit-loading]:hidden align-middle truncate leading-none gap-1",
          ["text-primary": match?("ghost", @variant)]
        ])
      }>
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end
end
