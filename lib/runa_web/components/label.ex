defmodule RunaWeb.Components.Label do
  @moduledoc """
  Renders a label.
  """

  use RunaWeb, :component

  attr :for, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class={
        classes([
          "flex flex-col items-start gap-1 text-sm leading-6 cursor-pointer",
          @class
        ])
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </label>
    """
  end
end
