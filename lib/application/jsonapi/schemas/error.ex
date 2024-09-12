defmodule RunaWeb.JSONAPI.Schemas.Error do
  @moduledoc """
  The schema for error object.
  """
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    type: :object,
    description: "Response schema for failed operation",
    additionalProperties: false,
    properties: %{
      errors: %Schema{
        type: :array,
        items: %Schema{
          type: :object,
          properties: %{
            status: %Schema{
              type: :string,
              description:
                "the HTTP status code applicable to this problem, expressed as a string value."
            },
            title: %Schema{
              type: :string,
              description:
                "a short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization."
            }
          },
          required: [:status, :title]
        }
      }
    },
    required: [:errors]
  })
end
