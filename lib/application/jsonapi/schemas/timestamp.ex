defmodule RunaWeb.JSONAPI.Schemas.Timestamp do
  require OpenApiSpex

  alias OpenApiSpex.Schema

  @moduledoc """
  The schema for JSONAPI timestamp object.
  """
  OpenApiSpex.schema(%{
    type: :object,
    description:
      "an attributes object representing timestamps of creation and update",
    properties: %{
      attributes: %Schema{
        type: :object,
        properties: %{
          inserted_at: %Schema{
            type: :string,
            description: "ISO 8601 date of creation",
            format: :"date-time"
          },
          updated_at: %Schema{
            type: :string,
            description: "ISO 8601 date of update",
            format: :"date-time"
          },
          inserted_at_timestamp: %Schema{
            type: :string,
            description: "UNIX timestamp of creation",
            format: :int64,
            minimum: 0
          },
          updated_at_timestamp: %Schema{
            type: :string,
            description: "UNIX timestamp of update",
            format: :int64,
            minimum: 0
          }
        },
        required: [
          :inserted_at,
          :updated_at,
          :inserted_at_timestamp,
          :updated_at_timestamp
        ]
      }
    }
  })
end
