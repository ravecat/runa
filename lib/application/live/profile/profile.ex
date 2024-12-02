defmodule RunaWeb.Live.Profile do
  use RunaWeb, :live_view

  alias Runa.Accounts
  alias Runa.Tokens.Token

  import RunaWeb.Components.Dropdown
  import RunaWeb.Components.Tab
  import RunaWeb.Components.Info
  import RunaWeb.Components.Avatar
  import RunaWeb.Components.Button
  import RunaWeb.Components.Icon
  import RunaWeb.Formatters

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    case Accounts.get(user_id) do
      {:ok, user} ->
        socket =
          socket
          |> assign(access_levels: Token.access_levels())
          |> assign(user: user)

        {:ok, socket}

      {:error, %Ecto.NoResultsError{}} ->
        socket =
          socket
          |> put_flash(:error, "User not found")
          |> redirect(to: ~p"/")

        {:ok, socket}

      _ ->
        {:ok, redirect(socket, to: ~p"/")}
    end
  end

  @impl true
  def handle_params(
        _params,
        _url,
        %{assigns: %{live_action: :show}} = socket
      ) do
    {:noreply, assign(socket, :page_title, "Profile")}
  end
end
