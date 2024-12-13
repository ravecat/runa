defmodule RunaWeb.Components.Dropdown do
  @moduledoc """
  Renders a dropdown.

  ## Examples
    <.dropdown>
      <:summary>
        Hello! Choose an option
      </:summary>
      <:menu>
        <.link href="#">Profile</.link>
        <.link href="#">Settings</.link>
        <.link href="#">Logout</.link>
      </:menu>
      <:footer>
        <.button>Footer</.button>
      </:footer>
    </.dropdown>
  """
  use RunaWeb, :component

  import RunaWeb.Components.Icon

  attr :id, :string, required: true
  attr :entries, :list, required: true

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each entry data to the row content"

  attr :row_click, :any,
    default: nil,
    doc: "the function for handling phx-click on each row"

  attr :class, :string, default: nil

  attr :row_id, :any,
    default: nil,
    doc: "the function for generating the row id"

  attr :rest, :global

  attr :position, :string,
    default: "bottom",
    values: ["top", "bottom", "left", "right"]

  slot :summary do
    attr :class, :string
  end

  slot :row
  slot :footer

  def dropdown(assigns) do
    assigns =
      with %{entries: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assigns
        |> assign(row_id: assigns.row_id || fn {id, _item} -> id end)
        |> assign(row_item: fn {_, item} -> assigns.row_item.(item) end)
        |> assign(
          row_click:
            assigns.row_click && fn {_, item} -> assigns.row_click.(item) end
        )
      end

    ~H"""
    <details
      phx-click-away={JS.remove_attribute("open")}
      role="menu"
      aria-orientation="vertical"
      data-state="closed"
      class={[
        "group relative phx-submit-loading:opacity-75",
        @class
      ]}
      {@rest}
    >
      <summary class="list-none rounded flex items-center border cursor-pointer w-full p-[.5rem] select-none bg-background dark:bg-background overflow-hidden">
        <div class="overflow-hidden text-ellipsis whitespace-nowrap flex-1">
          <%= if @summary != [] do %>
            {render_slot(@summary)}
          <% else %>
            Select an option
          <% end %>
        </div>
        <.icon
          :if={@summary != []}
          icon="shevron-right"
          class="rotate-90 transition-transform duration-300 group-open:rotate-[270deg] flex-shrink-0"
        />
      </summary>
      <div
        class="absolute p-1 rounded border shadow-lg bg-background dark:bg-background z-10 min-w-[100%] max-h-[80vh]"
        style={[
          %{
            "top" => [
              "transform: translate(0, calc(-100% - 0.25rem));",
              "top: 0;"
            ],
            "bottom" => [
              "transform: translate(0, calc(0% + 0.25rem));"
            ],
            "left" => [
              "transform: translate(calc(-100% - 0.25rem), 0);",
              "top: 0;"
            ],
            "right" => [
              "transform: translate(calc(100% + 0.25rem), 0);",
              "top: 0;",
              "right: 0"
            ]
          }[@position]
        ]}
      >
        <ul
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @entries) && "stream"}
          id={@id}
        >
          <li
            :for={row <- @entries}
            phx-click={@row_click && @row_click.(row)}
            class="rounded flex items-center p-2 gap-[.25rem] truncate cursor-pointer hover:bg-background-hover"
            id={@row_id && @row_id.(row)}
          >
            <%= if @row != [] do %>
              {render_slot(@row, @row_item.(row))}
            <% else %>
              {@row_item.(row)}
            <% end %>
          </li>
        </ul>

        <div
          :if={@footer != []}
          id="footer"
          class="rounded flex items-center p-2 gap-[.25rem] truncate cursor-pointer"
        >
          {render_slot(@footer)}
        </div>
      </div>
    </details>
    """
  end
end
