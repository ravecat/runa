defmodule RunaWeb.Components.Info do
  @moduledoc """
  Renders an info block with title and info data.
  """
  use RunaWeb, :html

  slot :inner_block
  slot :info
  slot :title
  attr :class, :string, default: nil
  attr :rest, :global

  def info(assigns) do
    ~H"""
    <div class={["flex flex-col", @class]} {@rest}>
      <strong :if={@title != []} class="block font-medium">
        {render_slot(@title)}
      </strong>
      <span :if={@info != []} class="block">
        {render_slot(@info)}
      </span>
    </div>
    """
  end
end
