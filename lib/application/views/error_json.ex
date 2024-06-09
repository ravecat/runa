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
  def render(template, _assigns) do
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
  end

  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.

    %{
      errors:
        Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        |> Enum.map(fn {field, messages} ->
          Enum.map(messages, fn message ->
            %{
              title: "#{field} #{message}",
              source: %{pointer: "/data/attributes/#{field}"}
            }
          end)
        end)
        |> List.flatten()
    }
  end

  defp translate_error({msg, opts}) do
    # You can make use of gettext to translate error messages by
    # uncommenting and adjusting the following code:

    # if count = opts[:count] do
    #   Gettext.dngettext(RunaWeb.Gettext, "errors", msg, msg, count, opts)
    # else
    #   Gettext.dgettext(RunaWeb.Gettext, "errors", msg, opts)
    # end

    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end
end
