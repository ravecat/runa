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

  def update(assigns, socket) do
    active_team = List.first(assigns.user.teams || [])

    {:ok,
     socket
     |> assign(assigns)
     |> assign(active_team: active_team)
     |> assign_new(:team_changeset, fn -> to_form(Teams.change(%Team{})) end)}
  end

  def render(assigns) do
    ~H"""
    <aside class="flex h-screen flex-col bg-background">
      <div class="px-[1rem] py-[1rem]">
        <.icon icon="logo" class="w-[4rem]" />
      </div>
      <div class="px-[.5rem]">
        <.dropdown position="right">
          <:summary>
            <.tab class="cursor-pointer hover:bg-secondary">
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
              class="cursor-pointer hover:bg-secondary"
            >
              <.link :if={team} href="#">
                <%= team.title %>
              </.link>
            </.tab>
          </:menu>
          <:footer>
            <.tab
              type="button"
              phx-click={show_modal("create")}
              class="cursor-pointer hover:bg-secondary"
            >
              Create team
            </.tab>
          </:footer>
        </.dropdown>
        <.link href={~p"/session/logout"} method="delete">
          <.tab class="cursor-pointer hover:bg-secondary">
            <.icon icon="logout" /> Logout
          </.tab>
        </.link>
      </div>
      <.modal id="create">
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
      |> Teams.change(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, team_changeset: form)}
  end

  def handle_event("save", %{"team" => params}, socket) do
    case Teams.create(params) do
      {:ok, _} ->
        {:noreply, put_flash(socket, :info, "team created")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, team_changeset: to_form(changeset))}
    end
  end
end
