defmodule RunaWeb.Components.Navigation do
  @moduledoc """
  Provides a navigation menu component.

  ## Attributes
  - `id`: Required. Unique identifier for the root navigation element.
  - `class`: Optional. Additional CSS classes to apply to the root element.
  - `rest`: Optional. Additional global attributes to apply to the root element.

  ## Slots
  - `item`: Required. Defines the navigation items. Each item should contain a link or button.
  ## Example
      <.navigation id="main-nav" class="my-navigation">
        <:item>
          <a href="/">Home</a>
        </:item>
        <:item>
          <a href="/about">About</a>
        </:item>
      </.navigation>
  """
  use RunaWeb, :component

  attr :id, :string,
    required: true,
    doc: "Unique identifier for the root element."

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes to apply to the element."

  attr :rest, :global,
    doc: "Additional global attributes to apply to the element."

  slot :item, required: true

  def navigation(assigns) do
    ~H"""
    <nav id={@id} {@rest}>
      <ul
        aria-orientation="horizontal"
        role="menubar"
        class={["flex gap-2", @class]}
      >
        <%= for item <- @item do %>
          <li
            role="none"
            class={[
              "[&>a]:flex",
              "[&>a]:rounded",
              "[&>a]:items-center",
              "[&>a]:justify-center",
              "[&>a]:px-3",
              "[&>a]:h-[2rem]",
              "[&>a]:min-w-[5rem]",
              "[&>a]:text-sm",
              "[&>a]:font-medium",
              "[&>a]:bg-background",
              "[&>a]:hover:bg-background-hover",
              "[&>a]:text-primary"
            ]}
          >
            {render_slot(item)}
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
