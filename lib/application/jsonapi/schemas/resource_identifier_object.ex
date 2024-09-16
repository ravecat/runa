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
    required: [:type, :id],
    properties: %{
      type: %Schema{type: :string, description: "The type of the resource"},
      id: %Schema{type: :string, description: "The ID of the resource"},
      meta: Meta
    },
    additionalProperties: false
  })
end
