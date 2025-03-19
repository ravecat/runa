defmodule RunaWeb.Components.Pill do
  @moduledoc """
  Background and stroke element containing all other elements within it.
  """

  use RunaWeb, :component

  slot :inner_block
  attr :class, :string, default: nil
  attr :rest, :global

  def pill(assigns) do
    ~H"""
    <span
      class={
        classes([
          "flex-shrink-0 inline-flex items-center justify-start px-1 gap-1 text-ellipsis text-sm overflow-hidden whitespace-nowrap select-none cursor-pointer rounded",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
