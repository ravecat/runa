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
      class={[
        "icon inline-block min-w-[1rem] min-h-[1rem] align-text-top",
        @class
      ]}
      style={"--icon-url: url(/images/#{@icon}.svg);"}
      {@rest}
    >
    </span>
    """
  end
end
