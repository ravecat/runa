defmodule RunaWeb.Components.Form do
  @moduledoc """
  Renders a simple form.

  ## Examples

      <.custom_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]}/>
        <.input field={@form[:username]} />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.custom_form>
  """
  use RunaWeb, :component

  attr :for, Phoenix.HTML.Form,
    required: true,
    doc: "the datastructure for the form"

  attr :as, :any,
    default: nil,
    doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    doc: "the arbitrary HTML attributes to apply to the form tag"

  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def custom_form(assigns) do
    ~H"""
    <.form
      :let={f}
      class={classes(["flex flex-col gap-2", @class])}
      for={@for}
      as={@as}
      {@rest}
    >
      {render_slot(@inner_block, f)}
      <div :for={action <- @actions} class="flex gap-[1rem] justify-end">
        {render_slot(action, f)}
      </div>
    </.form>
    """
  end
end
