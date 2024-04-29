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
    <aside class="flex h-screen flex-col bg-accent-50">
      <div class="px-[1rem] py-[1rem]">
        <.icon icon="logo" class="w-[4rem]" />
      </div>
      <div class="px-[.5rem]">
        <.dropdown position="right">
          <:summary>
            <.tab class="cursor-pointer hover:bg-accent-100 hover:text-accent-700">
              <.avatar alt="" src={@user.avatar} />
              <.info class="grow text-sm">
                <:title><%= @active_team.title || "-" %></:title>
                <:info><%= @user.name %></:info>
              </.info>
              <.icon icon="shevron-right" />
            </.tab>
          </:summary>
          <:menu>
            <%= for team <- @user.teams do %>
              <.tab class="cursor-pointer hover:bg-secondary-50">
                <.link :if={team} href="#">
                  <%= team.title %>
                </.link>
              </.tab>
            <% end %>
          </:menu>
          <:footer>
            <.tab
              type="button"
              phx-click={show_modal("create-team")}
              class="cursor-pointer hover:bg-secondary-50"
            >
              Create team
            </.tab>
          </:footer>
        </.dropdown>
        <%= for row <- @rows do %>
          <.link href="#">
            <.tab class="cursor-pointer hover:bg-accent-100 hover:text-accent-700">
              <.icon icon={row[:icon]} />
              <%= row[:title] %>
            </.tab>
          </.link>
        <% end %>
      </div>
      <.modal id="create-team">
        <:title>
          Create team
        </:title>
        <:content>Let's create</:content>
      </.modal>
    </aside>
    """
  end
end
