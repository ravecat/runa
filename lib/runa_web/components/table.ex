defmodule RunaWeb.Components.Table do
  @moduledoc """
  This module is responsible for rendering a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user}><%= user.id %></:col>
        <:col :let={user}><%= user.username %></:col>
      </.table>
  """
  use RunaWeb, :component

  attr(:id, :string, required: true)
  attr(:rows, :list, required: true)

  attr(:row_id, :any,
    default: nil,
    doc: "the function for generating the row id"
  )

  attr(:row_click, :any,
    default: nil,
    doc: "the function for handling phx-click on each row"
  )

  attr(:row_item, :any,
    default: &Function.identity/1,
    doc:
      "the function for mapping each row before calling the :col and :action slots"
  )

  attr(:class, :string, default: "")
  attr(:rest, :global)

  slot :col, required: true do
    attr(:label, :string)
    attr(:class, :string)
  end

  slot(:action,
    doc: "the slot for showing user actions in the last table column"
  )

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
      |> assign(show_header?: Enum.any?(assigns.col, & &1[:label]))

    ~H"""
    <table
      class={
        classes([
          "min-w-full table-fixed",
          [
            "divide-y divide-background-alt dark:divide-background-alt":
              @show_header?
          ],
          @class
        ])
      }
      {@rest}
    >
      <thead
        :if={@show_header?}
        class="text-left whitespace-nowrap uppercase text-sm"
      >
        <tr>
          <th
            :for={col <- @col}
            class={
              classes([
                "p-2 font-medium max-w-64 truncate",
                col[:class]
              ])
            }
          >
            {col[:label]}
          </th>
          <th :if={@action != []} class="relative w-20"></th>
        </tr>
      </thead>
      <tbody
        id={@id}
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        class="relative divide-y divide-background-alt dark:divide-background-alt text-sm"
      >
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)}>
          <td
            :for={col <- @col}
            phx-click={@row_click && @row_click.(row)}
            class={
              classes([
                "p-2 max-w-64 truncate",
                col[:class]
              ])
            }
          >
            {render_slot(col, @row_item.(row))}
          </td>
          <td :if={@action != []} class="p-2 max-w-64 grid place-items-center">
            <%= for action <- @action do %>
              {render_slot(action, @row_item.(row))}
            <% end %>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end
end
