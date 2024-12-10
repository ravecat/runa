defmodule RunaWeb.Components.Table do
  @moduledoc """
  This module is responsible for rendering a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  use RunaWeb, :component

  attr :id, :string, required: true
  attr :rows, :list, required: true

  attr :row_id, :any,
    default: nil,
    doc: "the function for generating the row id"

  attr :row_click, :any,
    default: nil,
    doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc:
      "the function for mapping each row before calling the :col and :action slots"

  attr :class, :string, default: ""
  attr :rest, :global

  slot :col, required: true do
    attr :label, :string
  end

  slot :action,
    doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assigns
        |> assign(row_id: assigns.row_id || fn {id, _item} -> id end)
        |> assign(row_item: fn {_, item} -> assigns.row_item.(item) end)
        |> assign(
          row_click:
            assigns.row_click && fn {_, item} -> assigns.row_click.(item) end
        )
      end

    ~H"""
    <div class="overflow-y-auto sm:overflow-visible">
      <table
        class={[
          "min-w-full divide-y divide-secondary dark:divide-secondary",
          @class
        ]}
        {@rest}
      >
        <thead class="text-left whitespace-nowrap uppercase text-sm">
          <tr>
            <th :for={col <- @col} class="p-2 font-medium">
              {col[:label]}
            </th>
            <th :if={@action != []} class="relative"></th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
          class="relative divide-y divide-secondary dark:divide-secondary text-sm"
        >
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
            <td
              :for={{col, _} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class="whitespace-nowrap p-2"
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="flex whitespace-nowrap p-2">
              <%= for action <- @action do %>
                {render_slot(action, @row_item.(row))}
              <% end %>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end