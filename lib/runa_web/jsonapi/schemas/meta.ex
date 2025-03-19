defmodule RunaWeb.JSONAPI.Schemas.Meta do
  require OpenApiSpex

  @moduledoc """
  The schema for JSONAPI meta object.
  """

  OpenApiSpex.schema(%{
    type: :object,
    descrition: "Meta object according to JSON:API specification"
  })
end
