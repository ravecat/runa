defmodule RunaWeb.Schemas.Files do
  @moduledoc """
  The file schemas, thats belongs to a project.
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schema,
    name: "files",
    schema: %Schema{
      type: :object,
      properties: %{
        attributes: %Schema{
          type: :object,
          properties: %{
            filename: %Schema{
              type: :string,
              description: "File name",
              pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
            }
          },
          required: [:filename]
        }
      }
    }
end
