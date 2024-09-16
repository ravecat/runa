defmodule RunaWeb.JSONAPI.Schemas.Document do
  @moduledoc """
  The schema for JSONAPI document object.
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.LinksObject
  alias RunaWeb.JSONAPI.Schemas.ResourceObject
  alias RunaWeb.JSONAPI.Schemas.Timestamp

  OpenApiSpex.schema(%{
    oneOf: [
      %Schema{
        type: :object,
        description: "Document schema for empty response",
        properties: %{},
        additionalProperties: false
      },
      %Schema{
        type: :object,
        description: "Document schema for successed operation",
        properties: %{
          links: LinksObject,
          data: %Schema{
            oneOf: [
              %Schema{
                type: :object,
                allOf: [
                  ResourceObject,
                  Timestamp
                ]
              },
              %Schema{
                type: :array,
                items: %Schema{
                  type: :object,
                  allOf: [
                    ResourceObject,
                    Timestamp
                  ]
                }
              }
            ]
          },
          included: %Schema{
            type: :array,
            items: ResourceObject
          }
        },
        required: [:data],
        additionalProperties: false
      }
    ]
  })
end
