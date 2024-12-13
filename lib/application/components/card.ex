defmodule RunaWeb.Components.Card do
  @moduledoc """
  Renders a card component, which represents a block of content with a border and padding.
  """

  use RunaWeb, :component

  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, doc: "the slot for the card content", required: true

  def card(assigns) do
    ~H"""
    <div
      class={
        merge(
          "w-full p-4 rounded flex-col gap-4 flex border overflow-hidden shadow-sm transition hover:shadow",
          @class
        )
        |> to_string()
      }
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end
end
