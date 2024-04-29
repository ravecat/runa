defmodule RunaWeb.Components.Modal do
  @moduledoc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import RunaWeb.Components.Commands
  import RunaWeb.Components.Icon
  import RunaWeb.Components.Button

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}
  slot :title, required: true
  slot :content, required: true

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="flex hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 justify-center items-center w-full md:inset-0 h-lvh max-h-full  backdrop-blur-sm"
      aria-overlay="true"
      aria-modal="true"
      aria-hidden={!@show}
      tabindex="-1"
      aria-labelledby={"#{@id}-title"}
      aria-describedby={"#{@id}-description"}
      role="dialog"
    >
      <div
        id={"#{@id}-bg"}
        class="fixed inset-0 bg-secondary-300 opacity-30 transition-opacity"
        aria-hidden="true"
      />
      <div
        id={"#{@id}-container"}
        phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
        phx-key="escape"
        phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
        class="relative p-4 w-full max-w-2xl max-h-full"
      >
        <div class="relative bg-background rounded shadow-lg" id={"#{@id}-content"}>
          <div class="flex justify-between items-center py-3 px-4">
            <h3 class="text-text text-lg">
              <%= render_slot(@title) %>
            </h3>
            <.icon
              phx-click={JS.exec("data-cancel", to: "##{@id}")}
              class="cursor-pointer p-[.5rem] opacity-20 hover:opacity-40"
              aria-label="close"
              type="button"
              icon="x-mark"
            />
          </div>
          <div class="p-[1rem] overflow-y-auto">
            <%= render_slot(@content) %>
          </div>
          <div class="flex gap-[1rem] justify-end p-4">
            <.button phx-click={JS.exec("data-cancel", to: "##{@id}")} type="button">
              Cancel
            </.button>
            <.button phx-click={@on_confirm} type="button">
              Ok
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}", display: "flex")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end