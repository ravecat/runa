defmodule RunaWeb.Schemas.JSONAPI.ResourceIdentifierObject do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.JSONAPI.Meta

  @moduledoc """
  The schema for JSONAPI resource identifier object.
  """
  OpenApiSpex.schema(%{
    type: :object,
    description: "A resource identifier object",
    oneOf: [
      %Schema{
        type: :object,
        required: [:type, :id],
        properties: %{
          type: %Schema{
            type: :string,
            description: "The type of the resource"
          },
          meta: Meta,
          id: %Schema{
            type: :string,
            description:
              "The ID of the resource. Required except when creating a new resource."
          }
        }
      },
      %Schema{
        type: :object,
        required: [:type, :lid],
        properties: %{
          type: %Schema{
            type: :string,
            description: "The type of the resource"
          },
          meta: Meta,
          lid: %Schema{
            type: :string,
            description:
              "A local ID for a new resource to be created on the server. Used instead of 'id' for new resources."
          }
        }
      }
    ]
  })
end
