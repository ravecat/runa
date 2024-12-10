defmodule RunaWeb.Components.Card do
  @moduledoc """
  Renders a card component, which represents a block of content with a border and padding.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import RunaWeb.Components.Commands

  attr :class, :string, default: ""
  attr :rest, :global

  slot :inner_block, doc: "the slot for the card content", required: true

  def card(assigns) do
    ~H"""
    <div
      class={[
        "w-full p-4 rounded flex-col gap-4 flex mb-4 border",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
