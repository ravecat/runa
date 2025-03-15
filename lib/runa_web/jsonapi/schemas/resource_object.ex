defmodule RunaWeb.JSONAPI.Schemas.ResourceObject do
  @moduledoc """
  The schema for JSONAPI resource object.
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.LinksObject
  alias RunaWeb.JSONAPI.Schemas.Meta
  alias RunaWeb.JSONAPI.Schemas.RelationshipObject

  OpenApiSpex.schema(%{
    type: :object,
    description: "Resource object according to JSON:API specification",
    required: [:type],
    properties: %{
      type: %Schema{type: :string, description: "Resource type"},
      id: %Schema{type: :string, description: "Resource ID"},
      attributes: %Schema{
        type: :object,
        description:
          "an attributes object representing some of the resource's data"
      },
      relationships: %Schema{
        type: :object,
        description:
          "a relationships object describing relationships between the resource and other JSON:API resources",
        additionalProperties: RelationshipObject
      },
      links: LinksObject,
      meta: Meta
    },
    additionalProperties: false
  })
end
