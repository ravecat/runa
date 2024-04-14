defmodule RunaWeb.Components.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use RunaWeb, :live_component
  use RunaWeb, :components

  @rows [
    %{
      title: "Projects",
      icon: "project",
      href: "/"
    },
    %{
      title: "Team",
      icon: "settings",
      href: "/"
    },
    %{
      title: "Profile",
      icon: "settings",
      href: "/"
    },
    %{
      title: "Logout",
      icon: "logout",
      href: "/"
    }
  ]

  def mount(socket) do
    {:ok, assign(socket, :rows, @rows)}
  end

  def render(assigns) do
    ~H"""
    <aside class="pa2 w5-ns bg-near-white h-100-ns h3">
      <div class="pa2 db-ns dn">
        <.icon icon="logo" class="w3 dark-gray" />
      </div>
      <div class="flex items-center w-100 pa2 pointer bg-animate hover-bg-moon-gray br2">
        <.avatar src={@user.avatar} />
        <div class="flex-grow-1 ml2 mr2">
          <div class="f6 fw4 mt0 mb0 black-60"><%= @user.name <> "'s Team" %></div>
          <div class="f6 f5-ns fw6 lh-title black mv0">
            <%= @user.name %>
            <span class="f6 fw4 mt0 mb0 black-60">(owner)</span>
          </div>
        </div>
        <div>
          <.icon icon="shevron-right" class="dark-gray" />
        </div>
      </div>
      <%= for row <- @rows do %>
        <.link
          class="flex align-items w-100-ns h2-ns no-underline dark-gray bg-animate hover-bg-moon-gray br2 pa2"
          href={row[:href]}
          title={row[:title]}
        >
          <div class="w1 w1-ns h1 h1-ns">
            <.icon icon={row[:icon]} class="dark-gray" />
          </div>
          <div class="f6 ml2"><%= row[:title] %></div>
        </.link>
      <% end %>
    </aside>
    """
  end
end
