defmodule RunaWeb.Live.Translation.Index do
  @moduledoc """
  LiveView for displaying and managing translation keys.
  Provides a table of translation keys with their associated translations.
  """
  use RunaWeb, :live_view

  alias Runa.Keys

  import RunaWeb.Components.Table

  @impl true
  def mount(_params, _session, socket) do
    {:ok, {keys, _}} = Keys.index()

    entities =
      Enum.map(keys, fn key ->
        {key, key.translations}
      end)

    socket = assign(socket, entities: entities, keys_count: length(keys))

    {:ok, socket}
  end

  def hello() do
    "Hello!"
  end
end
