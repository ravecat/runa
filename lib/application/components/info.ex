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
    <div class={["flex flex-column justify-center w-100 pa2", @class]} {@rest}>
      <div :if={@title != []} class="f7 f6-ns gray"><%= render_slot(@title) %></div>
      <div :if={@info != []} class="fw5 pa1 pl0 pr0"><%= render_slot(@info) %></div>
      <div :if={@inner_block}><%= render_slot(@inner_block) %></div>
    </div>
    """
  end
end
