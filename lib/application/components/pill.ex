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
        merge(
          "rounded inline-flex items-center justify-center p-[.25rem] gap-[.25rem] text-ellipsis text-sm overflow-hidden whitespace-nowrap select-none cursor-pointer",
          @class
        )
        |> to_string()
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
