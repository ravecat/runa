defmodule RunaWeb.Components.Flash do
  @moduledoc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  use RunaWeb, :html

  import RunaWeb.Components.Icon
  import RunaWeb.Components.Commands

  attr :id, :string, doc: "the optional id of flash container"

  attr :flash, :map,
    default: %{},
    doc: "the map of flash messages to display"

  attr :title, :string, default: nil

  attr :kind, :atom,
    values: [:info, :error],
    doc: "used for styling and flash lookup"

  attr :rest, :global,
    doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block,
    doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={
        msg =
          render_slot(@inner_block) ||
            Phoenix.Flash.get(@flash, @kind)
      }
      id={@id}
      phx-click={
        JS.push("lv:clear-flash", value: %{key: @kind})
        |> hide("##{@id}")
      }
      role="alert"
      class={[
        "fixed z-1 top-[1rem] right-[1rem] rounded border-s-4 p-[1rem] shadowable cursor-pointer",
        @kind == :info && "bg-success-100 text-success-600",
        @kind == :error && "bg-error-50 text-error"
      ]}
      {@rest}
    >
      <div :if={@title} class="flex items-center gap-2">
        <.icon :if={@kind == :info} class="h-5 w-5" icon="information-circle" />
        <.icon :if={@kind == :error} class="h-5 w-5" icon="exclamation-circle" />
        <strong class="block font-medium">{@title}</strong>
      </div>
      <p class="mt-2 text-sm text-red-700">{msg}</p>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map,
    required: true,
    doc: "the map of flash messages"

  attr :id, :string,
    default: "flash-group",
    doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon icon="arrow-path" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon icon="arrow-path" />
      </.flash>
    </div>
    """
  end
end
