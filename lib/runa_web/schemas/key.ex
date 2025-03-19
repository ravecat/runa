defmodule RunaWeb.Schemas.Keys do
  @moduledoc """
  The file schemas, thats belongs to a project.
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schema,
    name: "keys",
    schema: %Schema{
      type: :object,
      properties: %{
        attributes: %Schema{
          type: :object,
          properties: %{
            name: %Schema{
              type: :string,
              description: "Key name",
              pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
            },
            description: %Schema{
              type: :string,
              description: "Key description",
              pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/,
              nullable: true
            }
          },
          required: [:name]
        }
      }
    }
end
