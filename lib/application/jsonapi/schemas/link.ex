defmodule RunaWeb.JSONAPI.Schemas.Link do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.Meta

  @moduledoc """
  The schema for JSONAPI link object.
  """

  OpenApiSpex.schema(%{
    description: "A link object representing relationship",
    nullable: true,
    oneOf: [
      %Schema{type: :string, format: :uri},
      %Schema{
        type: :object,
        required: [:href],
        properties: %{
          href: %Schema{
            type: :string,
            format: :uri,
            description: "A URI-reference pointing to the link's target"
          },
          rel: %Schema{
            type: :string,
            description: "The link's relation type"
          },
          describedby: %Schema{
            type: :string,
            format: :uri,
            description: "A link to a description document for the link target"
          },
          title: %Schema{
            type: :string,
            description: "A human-readable label for the link's destination"
          },
          type: %Schema{
            type: :string,
            description: "The media type of the link's target"
          },
          hreflang: %Schema{
            oneOf: [
              %Schema{type: :string},
              %Schema{
                type: :array,
                items: %Schema{type: :string}
              }
            ],
            description: "The language(s) of the link's target"
          },
          meta: Meta
        }
      }
    ]
  })
end
