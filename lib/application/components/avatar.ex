defmodule RunaWeb.Components.Avatar do
  @moduledoc """
  Renders an icon.
  """
  use RunaWeb, :component

  attr :src, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    <img
      loading="lazy"
      src={@src}
      class={
        merge("size-10 rounded-full object-cover shadow-sm", @class) |> to_string()
      }
      {@rest}
    />
    """
  end
end
