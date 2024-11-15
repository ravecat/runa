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

  attr :position, :string,
    default: "bottom",
    values: ["top", "bottom", "left", "right"]

  slot :summary, required: true
  slot :menu, required: true
  slot :footer

  def dropdown(assigns) do
    ~H"""
    <details
      phx-click-away={JS.remove_attribute("open")}
      role="menu"
      aria-orientation="vertical"
      data-state="closed"
      class={[
        "phx-submit-loading:opacity-75 relative",
        @class
      ]}
      {@rest}
    >
      <summary class="list-none">
        <%= render_slot(@summary) %>
      </summary>
      <%!-- [TODO] Required css modules functionality https://ravecat.fibery.io/Runa/Features-282#Task/css-modules-integration-19 --%>
      <div
        class="absolute w-[16rem] rounded divide-y divide-secondary border border-secondary shadow-lg bg-background-50 dark:bg-background-50"
        style={[
          %{
            "top" => [
              "transform: translate(0, calc(-100% - 0.5rem));",
              "top: 0;"
            ],
            "bottom" => [
              "transform: translate(0, calc(0% + 0.5rem));"
            ],
            "left" => [
              "transform: translate(calc(-100% - 0.5rem), 0);",
              "top: 0;"
            ],
            "right" => [
              "transform: translate(calc(100% + 0.5rem), 0);",
              "top: 0;",
              "right: 0"
            ]
          }[@position]
        ]}
      >
        <div class="p-[.25rem]">
          <%= render_slot(@menu) %>
        </div>
        <div class="p-[.25rem]">
          <%= render_slot(@footer) %>
        </div>
      </div>
    </details>
    """
  end
end
