defmodule RunaWeb.Components.Dropdown do
  @moduledoc """
  Renders a dropdown.

  ## Examples
    <.dropdown>
      <:summary>
        Hello! Choose an option
      </:summary>
      <:row>
        <.link href="#">Profile</.link>
        <.link href="#">Settings</.link>
        <.link href="#">Logout</.link>
      </:row>
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

  slot :row do
    attr :class, :string
  end

  slot :footer do
    attr :class, :string
  end

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
      <summary class="list-none rounded flex items-center border cursor-pointer w-full p-2 select-none neutral overflow-hidden">
        <div class="truncate flex-1">
          <%= if @summary != [] do %>
            {render_slot(@summary)}
          <% else %>
            Select an option
          <% end %>
        </div>
        <.icon
          :if={@summary != []}
          icon="shevron-right"
          class="rotate-90 transition group-open:rotate-[270deg] flex-shrink-0"
        />
      </summary>
      <div class={
        classes([
          "absolute p-1 rounded border shadowable neutral z-10 w-full max-h-[80vh] flex gap flex gap-1 flex-col",
          [
            "translate-x-[0] translate-y-[calc(-100%-0.25rem)] top-[0]":
              match?("top", @position),
            "translate-x-[0] translate-y-[calc(0%+0.25rem)]":
              match?("bottom", @position),
            "translate-x-[calc(-100%-0.25rem)] translate-y-[0] top-[0]":
              match?("left", @position),
            "translate-x-[calc(100%+0.25rem)] translate-y-[0] top-[0] right-[0]":
              match?("right", @position)
          ]
        ])
      }>
        <ul
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @entries) && "stream"}
          class="flex flex-col gap-1"
          id={@id}
        >
          <li
            :for={row <- @entries}
            phx-click={@row_click && @row_click.(row)}
            class={
              classes([
                "optionable truncate cursor-pointer ghost",
                get_in(@row, [Access.at(0), :class])
              ])
            }
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
          class={
            classes([
              "rounded flex items-center h-8 truncate cursor-pointer",
              get_in(@footer, [Access.at(0), :class])
            ])
          }
        >
          {render_slot(@footer)}
        </div>
      </div>
    </details>
    """
  end
end
