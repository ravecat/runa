defmodule RunaWeb.Live.Token.Form do
  @moduledoc """
  Form for creating and updating API tokens.
  """

  use RunaWeb, :live_component

  alias Runa.Tokens
  alias Runa.Tokens.Token

  import RunaWeb.Components.Form
  import RunaWeb.Components.Input
  import RunaWeb.Components.Select

  @impl true
  def update(%{data: %Token{} = data} = assigns, socket) do
    action = if data.id, do: :edit, else: :new

    socket =
      socket
      |> assign(assigns)
      |> assign(:action, action)
      |> assign_new(:access, fn ->
        Enum.map(Token.access_levels(), fn {label, _} -> {label, label} end)
      end)
      |> assign_new(:form, fn -> to_form(Tokens.change(data)) end)

    {:ok, socket}
  end

  slot(:actions, doc: "the slot for form actions, such as a submit button")

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.custom_form
        id={@id}
        for={@form}
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
        aria-label="Token form"
      >
        <.input type="hidden" field={@form[:user_id]} value={to_string(@user.id)} />
        <.input type="text" field={@form[:title]}>
          <:label>Title</:label>
        </.input>
        <.select field={@form[:access]} options={@access}>
          <:label>Access</:label>
        </.select>
        {render_slot(@actions, @form)}
      </.custom_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"token" => attrs}, socket) do
    changeset = Tokens.change(socket.assigns.data, attrs)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"token" => attrs}, socket) do
    save(socket, socket.assigns.action, attrs)
  end

  defp save(socket, :edit, attrs) do
    case Tokens.update(socket.assigns.data, attrs) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end

  defp save(socket, :new, attrs) do
    case Tokens.create(attrs) do
      {:ok, _} ->
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end
end
