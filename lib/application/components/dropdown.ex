defmodule RunaWeb.Components.Dropdown do
  @moduledoc """
  Renders a dropdown.

  ## Examples
    <.dropdown>
      <:button><.button>Send!</.button></:button>
      <:menu>
        <.link href="#">Profile</.link>
        <.link href="#">Settings</.link>
        <.link href="#">Logout</.link>
      </:menu>
    </.dropdown>
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr :class, :string, default: nil
  attr :rest, :global
  attr :position, :string, default: "bottom", values: ["top", "bottom", "left", "right"]

  slot :button, required: true
  slot :menu, required: true

  def dropdown(assigns) do
    ~H"""
    <details
      phx-click-away={JS.toggle_attribute({"open", "false"})}
      class={[
        "phx-submit-loading:opacity-75 relative",
        @class
      ]}
      {@rest}
    >
      <summary class="list">
        <%= render_slot(@button) %>
      </summary>
      <%!-- [TODO] Required css modules functionality https://ravecat.fibery.io/Runa/Features-282#Task/css-modules-integration-19 --%>
      <div
        class="absolute pa1 bg-white w5 z-1 shadow-4 br2 ba b--moon-gray"
        style={
          %{
            "top" => ["transform: translate(0, calc(-100% - 0.5rem));", "top: 0;"],
            "bottom" => ["transform: translate(0, calc(0% + 0.5rem));"],
            "left" => ["transform: translate(calc(-100% - 0.5rem), 0);", "top: 0;"],
            "right" => ["transform: translate(calc(100% + 0.5rem), 0);", "top: 0;", "right: 0"]
          }[@position]
        }
      >
        <%= render_slot(@menu) %>
      </div>
    </details>
    """
  end
end
