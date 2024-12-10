defmodule RunaWeb.Components.Tab do
  @moduledoc """
  Renders an info block with title and info data.
  """
  use RunaWeb, :html

  slot :inner_block
  attr :class, :string, default: nil
  attr :rest, :global

  def tab(assigns) do
    ~H"""
    <div
      class={[
        "rounded flex items-center p-[.5rem] gap-[.25rem] text-ellipsis overflow-hidden whitespace-nowrap",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
