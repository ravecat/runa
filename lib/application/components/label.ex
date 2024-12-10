defmodule RunaWeb.Components.Label do
  @moduledoc """
  Renders a label.
  """

  use RunaWeb, :component

  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class="flex items-center gap-1 text-sm leading-6 cursor-pointer"
    >
      {render_slot(@inner_block)}
    </label>
    """
  end
end
