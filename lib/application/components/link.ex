defmodule RunaWeb.Components.Link do
  @moduledoc """
  Provides link component with activity mark.
  """
  use Phoenix.Component

  @doc """
  Renders a link with active state detection based on current URI.

  Extends Phoenix.Component.link/1 with additional functionality for automatically
  applying active classes and attributs when the link matches the current URI.

  ## Attributes

  ### Optional
  - `:current_uri` (string) - The current full URI of the page (usually from socket.assigns)
  - `:match` (:atom) - Matching strategy for URI comparison.
    - `:exact` - exact path match (default)
    - `:prefix` - match when current URI starts with target path
  - `:match_params` (:boolean) - Whether to consider query parameters in comparison. Default false.
  - `:active_class` (string) - CSS class to apply when active. Default "active".

  ## Examples

      <.active_link
        patch={~p"/projects/20"}
        current_uri={@current_uri}
        class="nav-link"
        match={:prefix}
        active_class="bg-blue-500"
      >
        Project Details
      </.active_link>
  """

  attr :navigate, :string,
    doc: """
    Navigates to a LiveView.
    When redirecting across LiveViews, the browser page is kept, but a new LiveView process
    is mounted and its contents is loaded on the page. It is only possible to navigate
    between LiveViews declared under the same router
    [`live_session`](`Phoenix.LiveView.Router.live_session/3`).
    When used outside of a LiveView or across live sessions, it behaves like a regular
    browser redirect.
    """

  attr :patch, :string,
    doc: """
    Patches the current LiveView.
    The `handle_params` callback of the current LiveView will be invoked and the minimum content
    will be sent over the wire, as any other LiveView diff.
    """

  attr :href, :any,
    doc: """
    Uses traditional browser navigation to the new location.
    This means the whole page is reloaded on the browser.
    """

  attr :replace, :boolean,
    default: false,
    doc: """
    When using `:patch` or `:navigate`,
    should the browser's history be replaced with `pushState`?
    """

  attr :method, :string,
    default: "get",
    doc: """
    The HTTP method to use with the link. This is intended for usage outside of LiveView
    and therefore only works with the `href={...}` attribute. It has no effect on `patch`
    and `navigate` instructions.

    In case the method is not `get`, the link is generated inside the form which sets the proper
    information. In order to submit the form, JavaScript must be enabled in the browser.
    """

  attr :csrf_token, :any,
    default: true,
    doc: """
    A boolean or custom token to use for links with an HTTP method other than `get`.
    """

  attr :match_params, :boolean, default: true
  attr :match, :any, default: :exact
  attr :current_uri, :string, default: "/"
  attr :active_class, :string, default: "active"

  attr :rest, :global,
    doc: """
    Additional HTML attributes added to the `a` tag.
    """

  slot :inner_block,
    required: true,
    doc: """
    The content rendered inside of the `a` tag.
    """

  def active_link(assigns) do
    uri = parse_uri(assigns.current_uri)
    target_uri = get_target_uri(assigns)

    active? =
      check_activity(
        uri,
        target_uri,
        match: assigns.match,
        match_params: assigns.match_params
      )

    assigns
    |> build_assigns(active?)
    |> Phoenix.Component.link()
  end

  defp parse_uri(uri) when is_binary(uri), do: URI.parse(uri)
  defp parse_uri(%URI{} = uri), do: uri

  defp get_target_uri(assigns) do
    cond do
      assigns[:patch] -> parse_uri(assigns.patch)
      assigns[:navigate] -> parse_uri(assigns.navigate)
      assigns[:href] -> parse_uri(assigns.href)
      true -> %URI{path: "/"}
    end
  end

  defp check_activity(current_uri, target_uri, opts) do
    current_path = current_uri.path || "/"
    target_path = target_uri.path || "/"

    path_matches? =
      case opts[:match] do
        :exact -> current_path == target_path
        :prefix -> String.starts_with?(current_path, target_path)
      end

    params_match? =
      if opts[:match_params] do
        current_uri.query == target_uri.query
      else
        true
      end

    path_matches? && params_match?
  end

  defp build_assigns(assigns, true) do
    rest =
      assigns.rest
      |> add_class(assigns[:active_class])
      |> add_aria_current()

    assign(assigns, :rest, rest)
  end

  defp build_assigns(assigns, _) do
    assigns
  end

  defp add_class(rest, active_class) do
    Map.put(rest, :class, [rest[:class], active_class])
  end

  defp add_aria_current(rest) do
    Map.put(rest, :"aria-current", "page")
  end
end
