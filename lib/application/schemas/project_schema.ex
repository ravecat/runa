defmodule RunaWeb.Schemas.Projects do
  require OpenApiSpex

  alias OpenApiSpex.Parameter
  alias OpenApiSpex.Reference
  alias OpenApiSpex.Schema

  defmodule Project do
    @moduledoc """
    The schema for project, thats belongs to a team.

    Project can have many files, keys, locales (languages).
    """
    OpenApiSpex.schema(%{
      allOf: [
        %Reference{
          "$ref": "#/components/schemas/ResourceObject"
        },
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
        %Reference{"$ref": "#/components/schemas/Document"},
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

  defmodule Params do
    @moduledoc false

    def path,
      do: [
        %Parameter{
          name: :id,
          in: :path,
          schema: %Schema{type: :integer, minimum: 1},
          description: "Resource ID",
          example: 1,
          required: true
        }
      ]
  end
end
