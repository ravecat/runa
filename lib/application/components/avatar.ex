defmodule RunaWeb.Components.Avatar do
  @moduledoc """
  Renders an icon.
  """
  use RunaWeb, :html

  attr :src, :string, required: true
  attr :class, :string, default: nil
  attr :rest, :global

  def avatar(assigns) do
    ~H"""
    <img src={@src} class={["size-10 rounded-full object-cover", @class]} {@rest} />
    """
  end
end
