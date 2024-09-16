defmodule RunaWeb.JSONAPI.Schemas.ResourceObject do
  @moduledoc """
  The schema for JSONAPI resource object.
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.Link
  alias RunaWeb.JSONAPI.Schemas.Meta
  alias RunaWeb.JSONAPI.Schemas.ResourceLinkage

  OpenApiSpex.schema(%{
    type: :object,
    required: [:type],
    additionalProperties: false,
    properties: %{
      type: %Schema{type: :string, description: "Resource type"},
      id: %Schema{type: :string, description: "Resource ID"},
      lid: %Schema{type: :string, description: "Resource local ID"},
      attributes: %Schema{
        type: :object,
        description:
          "an attributes object representing some of the resource's data"
      },
      relationships: %Schema{
        type: :object,
        description:
          "a relationships object describing relationships between the resource and other JSON:API resources",
        additionalProperties: ResourceLinkage
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