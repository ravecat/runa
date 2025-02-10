defmodule RunaWeb.Components.Commands do
  @moduledoc """
  JS commands for use in components.
  """

  alias Phoenix.LiveView.JS

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition: {"transition", "transition-0", "transition-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition: {"transition", "transition-100", "transition-0"}
    )
  end
end
