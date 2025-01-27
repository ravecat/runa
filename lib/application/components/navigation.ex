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
              "[&>a[aria-current='page']]:relative",
              "[&>a[aria-current='page']]:after:content-['']",
              "[&>a[aria-current='page']]:after:block",
              "[&>a[aria-current='page']]:after:h-[3px]",
              "[&>a[aria-current='page']]:after:w-full",
              "[&>a[aria-current='page']]:after:bg-accent",
              "[&>a[aria-current='page']]:after:absolute",
              "[&>a[aria-current='page']]:after:bottom-0",
              "[&>a[aria-current='page']]:after:left-0"
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
