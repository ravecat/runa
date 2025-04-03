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

  import RunaWeb.Adapters.Error

  def render(template, _assigns) do
    [status, _format] = String.split(template, ".")

    %{
      errors: [
        %{
          status: status,
          title: Phoenix.Controller.status_message_from_template(template),
          detail: Phoenix.Controller.status_message_from_template(template)
        }
      ]
    }
  end

  @doc """
  Renders errors.
  """
  def error(%{changeset: changeset, conn: %{status: status}}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{
      errors:
        Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
        |> Enum.map(fn {field, messages} ->
          Enum.map(messages, fn message ->
            %{
              status: to_string(status),
              title: "#{field} #{message}",
              source: %{pointer: "/data/attributes/#{field}"}
            }
          end)
        end)
        |> List.flatten()
    }
  end

  def error(%{error: error, conn: %{status: status}}) do
    %{
      errors: [
        %{
          status: to_string(status),
          title: error.message,
          detail: error.message
        }
      ]
    }
  end

  def error(%{errors: errors, conn: %{status: status}}) when is_list(errors) do
    %{
      errors:
        Enum.map(errors, fn error ->
          if match?(%OpenApiSpex.Cast.Error{}, error) do
            %{
              status: to_string(status),
              source: %{pointer: OpenApiSpex.path_to_string(error)},
              title: to_string(error)
            }
          else
            %{
              status: to_string(status),
              title: error.message,
              detail: error.message
            }
          end
        end)
    }
  end
end
