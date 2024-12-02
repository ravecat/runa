defmodule RunaWeb.Components.Button do
  @moduledoc """
  Renders a button.

  ## Examples
    <.button>Send!</.button>
    <.button phx-click="go" class="ml-2">Send!</.button>
  """
  use Phoenix.Component

  import RunaWeb.Components.Spinner

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      phx-disable-with=""
      type={@type || "button"}
      class={[
        "group",
        "phx-submit-loading:opacity-75",
        "inline-flex items-center justify-center rounded px-3 h-[2rem] min-w-[5rem] gap-2",
        "text-sm font-semibold text-background bg-primary hover:bg-accent text-background active:text-background/80",
        @class
      ]}
      {@rest}
    >
      <.spinner class="group-[.phx-click-loading]:block hidden" />
      <span class="group-[.phx-click-loading]:hidden">
        <%= render_slot(@inner_block) %>
      </span>
    </button>
    """
  end
end
