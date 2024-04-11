defmodule RunaWeb.Components.Icon do
  @moduledoc """
  Renders an icon.
  """
  use RunaWeb, :html

  attr :icon, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def icon(assigns) do
    ~H"""
    <span
      style={[
        "-webkit-mask: url(/images/#{@icon}.svg);",
        "mask: url(/images/#{@icon}.svg);",
        "-webkit-mask-repeat: no-repeat;",
        "mask-repeat: no-repeat;",
        "background-color: currentColor;"
      ]}
      class={["dib w1 h1 v-mid", @class]}
      {@rest}
    >
    </span>
    """
  end
end
