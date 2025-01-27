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
          "group border rounded flex items-center justify-center px-3 h-[2rem] min-w-[5rem] text-sm font-medium",
          "disabled:opacity-50 phx-submit-loading:opacity-75",
          case @variant do
            "primary" ->
              "bg-primary hover:bg-primary-400"

            "secondary" ->
              "bg-secondary hover:bg-secondary-400"

            "accent" ->
              "bg-accent hover:bg-accent-400"

            "warning" ->
              "bg-warning hover:bg-warning-400"

            "danger" ->
              "bg-danger hover:bg-danger-400"

            "ghost" ->
              "bg-background hover:bg-background-hover"

            _ ->
              "bg-primary hover:bg-primary-400"
          end,
          @class
        ])
        |> to_string()
      }
      {@rest}
    >
      <.spinner class={
        merge([
          "group-[.phx-submit-loading]:block hidden",
          if(@variant == "ghost", do: "text-primary", else: "text-background")
        ])
        |> to_string()
      } />
      <span class={
        merge([
          "group-[.phx-submit-loading]:hidden flex items-center justify-center align-middle leading-none gap-2",
          if(@variant == "ghost", do: "text-primary", else: "text-background")
        ])
        |> to_string()
      }>
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end
end
