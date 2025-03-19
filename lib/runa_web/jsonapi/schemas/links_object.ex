defmodule RunaWeb.JSONAPI.Schemas.LinksObject do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.Link

  @moduledoc """
  The schema for JSONAPI links object.
  """
  OpenApiSpex.schema(%Schema{
    type: :object,
    description: "Links object according to JSON:API specification",
    minProperties: 1,
    additionalProperties: Link
  })
end
