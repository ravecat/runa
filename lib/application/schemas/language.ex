defmodule RunaWeb.Schemas.Languages do
  @moduledoc """
  The laguage schemas, thats describe languages available in the system.
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schema,
    name: :language,
    schema: %Schema{
      type: :object,
      properties: %{
        attributes: %Schema{
          type: :object,
          properties: %{
            title: %Schema{
              type: :string,
              description: "Language title",
              pattern: ~r/[a-zA-Z][a-zA-Z_\s]+/
            },
            wals_code: %Schema{
              type: :string,
              description: "WALS code",
              pattern: ~r/[a-zA-Z]+/
            },
            iso_code: %Schema{
              type: :string,
              description: "ISO code",
              pattern: ~r/[a-zA-Z]+/,
              nullable: true
            },
            glotto_code: %Schema{
              type: :string,
              description: "Glotto code",
              pattern: ~r/[a-zA-Z]+/,
              nullable: true
            }
          },
          required: [:title, :wals_code]
        }
      }
    }
end
