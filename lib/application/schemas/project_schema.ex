defmodule RunaWeb.Schemas.Projects do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.Common, as: CommonSchemas

  defmodule Project do
    @moduledoc """
    The schema for project, thats belongs to a team.

    Project can have many files, keys, locales (languages).
    """
    OpenApiSpex.schema(%{
      allOf: [
        CommonSchemas.ResourceObject,
        %Schema{
          type: :object,
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
        }
      ]
    })
  end

  defmodule ShowResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Project.ShowResponse",
      description: "The schema for resource show response",
      type: :object,
      allOf: [
        CommonSchemas.Document,
        %Schema{
          type: :object,
          properties: %{
            data: Project
          }
        }
      ],
      example: %{
        "data" => %{
          "type" => "teams",
          "id" => "1",
          "attributes" => %{
            "name" => "name",
            "description" => "description",
            "inserted_at" => "2021-01-01T00:00:00Z",
            "updated_at" => "2021-01-01T00:00:00Z",
            "inserted_at_timestamp" => "1609836000",
            "updated_at_timestamp" => "1609836000"
          }
        }
      }
    })
  end
end
