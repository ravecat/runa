defmodule RunaWeb.Live.File.Index do
  use RunaWeb, :live_view

  import RunaWeb.Components.Button
  import RunaWeb.Components.Card
  import RunaWeb.Components.Icon

  def mount(params, _session, socket) do
    dbg(params)
    {:ok, socket}
  end
end
