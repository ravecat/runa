defmodule RunaWeb.ErrorHTML do
  use RunaWeb, :html

  # If you want to customize your error pages,
  # uncomment the embed_templates/1 call below
  # and add pages to the error directory:
  #
  #   * lib/application/controllers/error_html/404.html.heex
  #   * lib/application/controllers/error_html/500.html.heex
  #
  # embed_templates "error_html/*"

  # The default is to render a plain text page based on
  # the template name. For example, "404.html" becomes
  # "Not Found".
  @spec render(any(), any()) :: <<_::16, _::_*8>>
  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
