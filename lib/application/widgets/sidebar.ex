defmodule RunaWeb.Components.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use Phoenix.Component
  use RunaWeb, :html

  attr :rows, :list,
    default: [
      %{
        title: "Workspaces",
        icon: "/images/workspace.svg",
        href: "/"
      },
      %{
        title: "Projects",
        icon: "/images/project.svg",
        href: "/"
      },
      %{
        title: "Settings",
        icon: "/images/settings.svg",
        href: "/"
      },
      %{
        title: "Logout",
        icon: "/images/logout.svg",
        href: "/"
      }
    ]

  def sidebar(assigns) do
    ~H"""
    <aside class="pa2 w5-ns bg-near-white h-100-ns h3">
      <div class="pa2 db-ns dn h2"><img class="dib h-100 dark-gray" src="/images/logo.svg" /></div>
      <div class="dt w-100 bb b--black-05 pa2">
        <div class="dtc w2 w2-ns v-mid">
          <img src="" class="ba b--black-10 db br-100 w2 w2-ns h2 h2-ns" />
        </div>
        <div class="dtc v-mid">
          <div class="f6 fw4 mt0 mb0 black-60">Max's team</div>
          <div class="f6 f5-ns fw6 lh-title black mv0">Max Sharov</div>
        </div>
      </div>
      <%= for row <- @rows do %>
        <.link
          class="dib flex w-100-ns h2-ns no-underline dark-gray bg-animate bg-near-white hover-bg-moon-gray items-center br2 pa2"
          href={row[:href]}
          title={row[:title]}
        >
          <div class="w1 w1-ns h1 h1-ns">
            <img  src={row[:icon]} />
          </div>
          <div class="f6 ml2"><%= row[:title] %></div>
        </.link>
      <% end %>
    </aside>
    """
  end
end
