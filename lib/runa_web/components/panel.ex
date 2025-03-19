defmodule RunaWeb.Components.Panel do
  @moduledoc """
  A versatile panel component for organizing content with optional header and footer sections.

  This component renders a containerized div with a standardized layout that includes:
  - An optional header section at the top
  - A main content area in the middle with overflow handling
  - An optional footer section at the bottom

  The panel has consistent styling with rounded corners, borders, and proper spacing.
  """

  use RunaWeb, :component

  attr(:class, :string, default: nil)
  attr(:rest, :global)

  slot :header do
    attr(:class, :string)
  end

  slot :footer do
    attr(:class, :string)
  end

  slot(:inner_block, required: true)

  def panel(assigns) do
    ~H"""
    <div
      class={
        classes([
          "grid grid-rows-[auto_1fr_auto] min-h-0 rounded border shadowable transition neutral divide-y divide-background-alt dark:divide-background-alt",
          @class
        ])
      }
      {@rest}
    >
      <div
        :if={@header != []}
        class={
          classes([
            "p-2",
            get_in(@header, [Access.at(0), :class])
          ])
        }
      >
        {render_slot(@header)}
      </div>

      <div class="p-2 overflow-auto">
        {render_slot(@inner_block)}
      </div>

      <div
        :if={@footer != []}
        class={
          classes([
            "p-2",
            get_in(@footer, [Access.at(0), :class])
          ])
        }
      >
        {render_slot(@footer)}
      </div>
    </div>
    """
  end
end
