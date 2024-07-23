defmodule RunaWeb.Schemas.Projects do
  @moduledoc """
  The project schemas, thats belongs to a team.

  Project can have many files, keys, locales (languages).
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schemas,
    name: "Project",
    properties: %{
      attributes: %Schema{
        type: :object,
        properties: %{
          name: %Schema{
            type: :string,
            description: "Project name",
            pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
          },
          description: %Schema{
            type: :string,
            description: "Project description",
            pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
          }
        },
        required: [:name]
      }
    }
end
