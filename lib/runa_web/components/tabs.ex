defmodule RunaWeb.Components.Tabs do
  @moduledoc """
  Provides a tabbed interface component.

  ## Attributes
  - `id`: Required. Unique identifier for the root tabs element.
  - `default`: Optional. Specifies the default tab to be shown on initial render.
  - `class`: Optional. Additional CSS classes to apply to the root element.
  - `rest`: Optional. Additional global attributes to apply to the root element.

  ## Slots
  - `tab`: Required. Defines the tab buttons. Each tab must have a `value` attribute.
  - `content`: Required. Defines the content panels associated with each tab. Each content panel must have a `value` attribute matching a tab's `value`.

  ## Example
      <.tabs id="settings" default="account">
        <:tab value="account">Account</:tab>
        <:tab value="profile">Profile</:tab>
        <:content value="account">Account settings content</:content>
        <:content value="profile">Profile settings content</:content>
      </.tabs>
  """
  use RunaWeb, :component

  import RunaWeb.Components.Button

  attr :id, :string,
    required: true,
    doc: "Unique identifier for the root tabs element."

  attr :default, :string,
    default: nil,
    doc: "Specifies the default tab to be shown on initial render."

  attr :class, :string,
    default: nil,
    doc: "Additional CSS classes to apply to the root element."

  attr :rest, :global,
    doc: "Additional global attributes to apply to the root element."

  slot :tab, required: true do
    attr :value, :string,
      required: true,
      doc: "Unique value identifying the tab."
  end

  slot :content, required: true do
    attr :value, :string,
      required: true,
      doc:
        "Unique value identifying the content panel, matching a tab's `value`."
  end

  def tabs(assigns) do
    ~H"""
    <div
      class={["flex flex-col gap-2", @class]}
      id={@id}
      phx-mounted={show_tab(@id, @default)}
      {@rest}
    >
      <div role="tablist" aria-orientation="horizontal" class="flex gap-2">
        <%= for tab <- @tab do %>
          <.button
            role="tab"
            variant="ghost"
            aria-selected="false"
            data-target={tab.value}
            phx-click={show_tab(@id, tab.value)}
          >
            {render_slot(tab)}
          </.button>
        <% end %>
      </div>
      <div
        :for={content <- @content}
        role="tabpanel"
        data-target={"#{content.value}-content"}
        hidden
      >
        {render_slot(content)}
      </div>
    </div>
    """
  end

  defp show_tab(id, value) do
    %JS{}
    |> JS.set_attribute({"aria-selected", "false"},
      to: "##{id} button[aria-selected='true']"
    )
    |> JS.set_attribute({"aria-selected", "true"},
      to: "##{id} [data-target=#{value}]"
    )
    |> JS.remove_class("!bg-accent !hover:bg-accent-400 !text-background",
      to: "##{id} button[aria-selected='false']"
    )
    |> JS.add_class("!bg-accent !hover:bg-accent-400 !text-background",
      to: "##{id} button[aria-selected='true']"
    )
    |> JS.remove_attribute("hidden",
      to: "##{id} [role='tabpanel'][data-target='#{value}-content']"
    )
    |> JS.set_attribute({"hidden", ""},
      to: "##{id} [role='tabpanel']:not([data-target='#{value}-content'])"
    )
  end
end
