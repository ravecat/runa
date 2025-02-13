defmodule RunaWeb.Live.File.Index do
  @moduledoc """
  LiveView for displaying and managing files.
  """

  use RunaWeb, :live_view

  import RunaWeb.Components.Icon

  alias Runa.Files

  @impl true
  def mount(_params, _session, socket) do
    extensions = Enum.map(Files.File.extensions(), &"#{to_string(&1)}")
    accept = Enum.map(extensions, &".#{&1}")

    socket =
      socket
      |> assign(files: [], extensions: extensions)
      |> allow_upload(:files,
        accept: accept,
        max_entries: 10,
        progress: &handle_upload_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel_upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  defp handle_upload_progress(_, %{done?: true} = entry, socket) do
    uploaded_file =
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        dest = Path.join("priv/static/uploads", Path.basename(path))

        File.cp!(path, dest)

        {:ok, entry}
      end)

    socket =
      update(
        socket,
        :files,
        &(&1 ++ [uploaded_file])
      )

    {:noreply, socket}
  end

  defp handle_upload_progress(_, _, socket) do
    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "Too large"

  defp error_to_string(:not_accepted),
    do: "You have selected an unacceptable file type"

  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
