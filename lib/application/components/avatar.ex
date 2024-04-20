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
    <img src={@src} class={["ba b--black-10 db br-100 w2 h2", @class]} {@rest} />
    """
  end
end
