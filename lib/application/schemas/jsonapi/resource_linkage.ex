defmodule RunaWeb.Schemas.JSONAPI.ResourceLinkage do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.JSONAPI.Link
  alias RunaWeb.Schemas.JSONAPI.Meta
  alias RunaWeb.Schemas.JSONAPI.ResourceIdentifierObject

  @moduledoc """
  The schema for JSONAPI resource linkage object.
  """
  OpenApiSpex.schema(%{
    type: :object,
    description:
      "A resource linkage allows a client to link together all of the included resource objects",
    required: [:data],
    properties: %{
      data: %Schema{
        nullable: true,
        oneOf: [
          ResourceIdentifierObject,
          %Schema{
            type: :array,
            items: ResourceIdentifierObject
          }
        ]
      },
      links: %Schema{
        type: :object,
        minProperties: 1,
        properties: %{
          self: Link,
          related: Link
        },
        additionalProperties: false
      },
      meta: Meta
    }
  })
end
