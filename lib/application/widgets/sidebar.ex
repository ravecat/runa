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
    socket =
      socket
      |> assign(:rows, @rows)

    {:ok, socket}
  end

  def render(assigns) do
    assigns = Map.put_new(assigns, :active_team, List.first(assigns.user.teams || []))

    ~H"""
    <aside class="pa2 w5-ns bg-near-white h-100-ns h3">
      <div class="pa3 pl2 db-ns dn">
        <.icon icon="logo" class="w3" />
      </div>
      <div class="flex items-center w-100 pa2 pointer bg-animate hover-bg-moon-gray br2">
        <.avatar src={@user.avatar} />
        <.info class="flex-grow-1 pt0 pb0">
          <:title><%= @active_team.title || "-" %></:title>
          <:info><%= @user.name %> <span class="f6 fw4">(owner)</span></:info>
        </.info>
        <.icon icon="shevron-right" />
      </div>
      <%= for row <- @rows do %>
        <.link class="no-underline dark-gray" href={row[:href]} title={row[:title]}>
          <div class="flex align-items bg-animate hover-bg-moon-gray br2 pa2">
            <.icon class="w1 w1-ns h1 h1-ns dib" icon={row[:icon]} />
            <span class="f6 ml2"><%= row[:title] %></span>
          </div>
        </.link>
      <% end %>
    </aside>
    """
  end
end
