defmodule RunaWeb.Schemas.Teams do
  @moduledoc """
  The team schemas, which are union of users and projects.

  Users related with team are contributors. Projects can be related only with one team.
  Users can be related with many teams.
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schemas,
    name: "Team",
    schema: %Schema{
      type: :object,
      properties: %{
        attributes: %Schema{
          type: :object,
          properties: %{
            title: %Schema{
              type: :string,
              description: "Team title",
              pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
            }
          },
          required: [:title]
        }
      }
    }
end
