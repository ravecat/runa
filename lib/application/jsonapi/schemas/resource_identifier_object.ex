defmodule RunaWeb.JSONAPI.Schemas.ResourceIdentifierObject do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.Meta

  @moduledoc """
  The schema for JSONAPI resource identifier object.
  """
  OpenApiSpex.schema(%{
    type: :object,
    description: "A resource identifier object",
    required: [:type],
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
      },
      lid: %Schema{
        type: :string,
        description:
          "A local ID for a new resource to be created on the server. Used instead of 'id' for new resources."
      }
    }
  })
end
