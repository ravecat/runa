defmodule RunaWeb.SaveRequestUri do
  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  def on_mount(_, _params, _session, socket) do
    {:cont,
     attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  defp save_request_path(_params, url, socket) do
    uri = URI.parse(url || "/")
    current_path = uri.path || "/"
    current_query = uri.query || ""

    full_uri =
      if current_query == "",
        do: current_path,
        else: "#{current_path}?#{current_query}"

    if socket.assigns[:current_uri] != full_uri do
      {:cont, assign(socket, :current_uri, full_uri)}
    else
      {:cont, socket}
    end
  end
end
