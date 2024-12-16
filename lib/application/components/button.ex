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

  attr :variant, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "warning", "danger", "ghost"]

  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={
        merge([
          "group flex items-center justify-center px-3 h-[2rem] min-w-[5rem] text-sm font-medium",
          "disabled:opacity-50 phx-submit-loading:opacity-75 border rounded",
          case @variant do
            "primary" ->
              "bg-primary hover:bg-primary-400 text-background"

            "secondary" ->
              "bg-secondary hover:bg-secondary-400 text-background"

            "accent" ->
              "bg-accent hover:bg-accent-400 text-background"

            "warning" ->
              "bg-warning hover:bg-warning-400 text-background"

            "danger" ->
              "bg-danger hover:bg-danger-400 text-background"

            "ghost" ->
              "bg-background hover:bg-background-hover text-primary"

            _ ->
              "bg-primary hover:bg-primary-400 text-background"
          end,
          @class
        ])
        |> to_string()
      }
      {@rest}
    >
      <.spinner class="group-[.phx-submit-loading]:block hidden" />
      <span class="group-[.phx-submit-loading]:hidden flex items-center justify-center align-middle leading-none gap-2">
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end
end
