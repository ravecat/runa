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
  use RunaWeb, :component

  attr :id, :string, default: "modal"
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}
  slot :title, required: true
  slot :content, required: true

  slot :actions,
    doc: "the slot for showing modal actions"

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="flex hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-10 justify-center items-center w-full md:inset-0 h-lvh max-h-full backdrop-blur-sm"
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
        class="fixed inset-0 secondary transition opacity-30"
        aria-hidden="true"
      />
      <div
        id={"#{@id}-container"}
        class="relative p-[4rem] w-full max-w-2xl max-h-full"
      >
        <div
          phx-key="escape"
          phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
          phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
          class="relative flex flex-col min-h-full gap-2 neutral rounded shadowable p-2 min-h-[10rem]"
          id={"#{@id}-content"}
        >
          <div class="flex justify-between items-center">
            <h3 class="text-lg">
              {render_slot(@title)}
            </h3>
          </div>
          <div class="overflow-visible">
            {render_slot(@content, {@on_cancel, @on_confirm})}
          </div>
          <div :if={@actions != []} class="flex justify-end gap-2">
            {render_slot(@actions, {@on_cancel, @on_confirm})}
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
      transition: {"transition", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100",
         "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(
      to: "##{id}",
      transition: {"block", "block", "hidden"}
    )
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end
end
