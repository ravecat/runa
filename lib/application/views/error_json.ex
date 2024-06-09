defmodule RunaWeb.ErrorJSON do
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end
  def render(template, assigns) do
    [code, _format] = String.split(template, ".")

    %{
      errors: [
        %{
          code: code,
          title: Phoenix.Controller.status_message_from_template(template),
          detail: Phoenix.Controller.status_message_from_template(template)
        }
      ]
    }
    |> Jason.encode!()
  end
end
