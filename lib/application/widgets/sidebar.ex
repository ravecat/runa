defmodule RunaWeb.Components.Sidebar do
  @moduledoc """
  Renders a application sidebar.
  """
  use RunaWeb, :live_component
  use RunaWeb, :components

  alias Runa.Teams
  alias Runa.Teams.Team
  alias RunaWeb.TeamHTML

  embed_templates "../templates/team/*"

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
    assigns = %{
      rows: @rows,
      team_changeset: to_form(Teams.change_team(%Team{}))
    }

    {:ok, assign(socket, assigns)}
  end

  def update(assigns, socket) do
    active_team = List.first(assigns.user.teams || [])

    assigns = Map.put(assigns, :active_team, active_team)

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
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
                <:title>
                  <%= @active_team.title || "-" %>
                </:title>
                <:info><%= @user.name %></:info>
              </.info>
              <.icon icon="shevron-right" />
            </.tab>
          </:summary>
          <:menu>
            <.tab
              :for={team <- @user.teams}
              class="cursor-pointer hover:bg-secondary-50"
            >
              <.link :if={team} href="#">
                <%= team.title %>
              </.link>
            </.tab>
          </:menu>
          <:footer>
            <.tab
              type="button"
              phx-click={show_modal("create_team")}
              class="cursor-pointer hover:bg-secondary-50"
            >
              Create team
            </.tab>
          </:footer>
        </.dropdown>
        <.link :for={row <- @rows} href="#">
          <.tab class="cursor-pointer hover:bg-accent-100 hover:text-accent-700">
            <.icon icon={row[:icon]} />
            <%= row[:title] %>
          </.tab>
        </.link>
      </div>
      <.modal id="create_team">
        <:title>
          Create team
        </:title>
        <:content>
          <%= Template.render(TeamHTML, "new", "html", assigns) %>
        </:content>
      </.modal>
    </aside>
    """
  end

  def handle_event("validate", %{"team" => params}, socket) do
    form =
      %Team{}
      |> Teams.change_team(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, team_changeset: form)}
  end

  def handle_event("save", %{"team" => params}, socket) do
    case Teams.create_team(params) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "team created")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, team_changeset: to_form(changeset))}
    end
  end
end
