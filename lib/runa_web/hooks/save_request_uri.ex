defmodule RunaWeb.SaveRequestUri do
  @moduledoc """
  Handles the storage of the current request URI in the LiveView socket.

  This module implements the `on_mount/4` callback to attach a hook that
  captures and stores the current request path and query parameters in the
  socket's assigns. It ensures the request URI is accessible throughout the
  LiveView lifecycle.
  """
  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  def on_mount(:params, _params, _session, socket) do
    {:cont,
     attach_hook(
       socket,
       :save_request_params,
       :handle_params,
       &save_request_params/3
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

  defp save_request_params(params, _url, socket) do
    {:cont, assign(socket, :current_params, params)}
  end
end
