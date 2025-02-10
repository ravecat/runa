defmodule RunaWeb.Components.Spinner do
  @moduledoc """
  Provides a spinner component for indicating loading states.

  This module implements a LiveComponent that renders a visually appealing
  spinner. It supports optional CSS classes and attributes, allowing for
  customization to fit various use cases within the application.
  """
  use RunaWeb, :component

  attr :class, :string, default: nil
  attr :rest, :global

  def spinner(assigns) do
    ~H"""
    <span
      class={
        classes([
          "spinner inline-block w-4 h-4 align-middle p-0.5 rounded-full bg-current",
          @class
        ])
      }
      {@rest}
    >
    </span>
    """
  end
end
