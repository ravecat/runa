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
      class={
        classes([
          "icon inline-block min-w-4 min-h-4 align-text-top align-middle",
          @class
        ])
      }
      style={"--icon-url: url(/images/#{@icon}.svg);"}
      {@rest}
    >
    </span>
    """
  end
end
