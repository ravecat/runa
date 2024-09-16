defmodule RunaWeb.JSONAPI.Schemas.RelationshipObject do
  require OpenApiSpex

  alias RunaWeb.JSONAPI.Schemas.LinksObject
  alias RunaWeb.JSONAPI.Schemas.Meta
  alias RunaWeb.JSONAPI.Schemas.ResourceLinkage

  @moduledoc """
  The schema for JSONAPI resource linkage object.
  """
  OpenApiSpex.schema(%{
    type: :object,
    description:
      "A resource linkage allows a client to link together all of the included resource objects",
    required: [:data],
    properties: %{
      data: ResourceLinkage,
      links: LinksObject,
      meta: Meta
    },
    additionalProperties: false
  })
end
