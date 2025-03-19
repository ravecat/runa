defmodule RunaWeb.Components.Avatar do
  @moduledoc """
  Renders an icon.
  """
  use RunaWeb, :component

  attr :src, :string, required: true
  attr :class, :string, default: ""
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    <img
      loading="lazy"
      src={@src}
      class={
        classes(["size-10 rounded-full object-cover border-2 shadowable", @class])
      }
      {@rest}
    />
    """
  end
end
