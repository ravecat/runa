defmodule RunaWeb.JSONAPI.Schemas.ResourceLinkage do
  @moduledoc """
  The schema for JSONAPI resource linkage object.
  """
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.ResourceIdentifierObject

  OpenApiSpex.schema(%{
    description:
      "A resource linkage allows a client to link together all of the included resource objects",
    oneOf: [
      ResourceIdentifierObject,
      %Schema{type: :array, items: ResourceIdentifierObject}
    ]
  })
end
