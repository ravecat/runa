defmodule RunaWeb.Schemas.JSONAPI.Document do
  @moduledoc """
  The schema for JSONAPI document object.
  """

  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.JSONAPI.Link
  alias RunaWeb.Schemas.JSONAPI.ResourceObject
  alias RunaWeb.Schemas.JSONAPI.Timestamp

  OpenApiSpex.schema(%{
    type: :object,
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
          links: %Schema{
            type: :object,
            minProperties: 1,
            properties: %{
              self: Link,
              first: Link,
              last: Link,
              prev: Link,
              next: Link
            },
            additionalProperties: false
          },
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
