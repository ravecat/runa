defmodule RunaWeb.Schemas.Teams do
  require OpenApiSpex

  alias OpenApiSpex.Parameter
  alias OpenApiSpex.Reference
  alias OpenApiSpex.Schema

  defmodule Team do
    @moduledoc """
    The schema for team, which are union of users and projects.

    Users related with team are contributors. Projects can be related only with one team.
    Users can be related with many teams.
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
      ]
    })
  end

  defmodule ShowResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Team.ShowResponse",
      description: "The schema for resource show response",
      type: :object,
      allOf: [
        %Reference{"$ref": "#/components/schemas/Document"},
        %Schema{
          type: :object,
          properties: %{
            data: Team
          }
        }
      ],
      example: %{
        "data" => %{
          "type" => "teams",
          "id" => "1",
          "attributes" => %{
            "title" => "title",
            "inserted_at" => "2021-01-01T00:00:00Z",
            "updated_at" => "2021-01-01T00:00:00Z",
            "inserted_at_timestamp" => "1609836000",
            "updated_at_timestamp" => "1609836000"
          }
        }
      }
    })
  end

  defmodule IndexResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Team.IndexResponse",
      description: "The schema for resource index response",
      type: :object,
      allOf: [
        %Reference{"$ref": "#/components/schemas/Document"},
        %Schema{
          type: :object,
          properties: %{
            data: %Schema{
              type: :array,
              items: Team
            }
          }
        }
      ],
      required: [:data],
      example: %{
        "data" => [
          %{
            "type" => "teams",
            "id" => "1",
            "attributes" => %{
              "title" => "title",
              "inserted_at" => "2021-01-01T00:00:00Z",
              "updated_at" => "2021-01-01T00:00:00Z",
              "inserted_at_timestamp" => "1609836000",
              "updated_at_timestamp" => "1609836000"
            }
          }
        ]
      }
    })
  end

  defmodule CreateBody do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Team.CreateBody",
      description: "The body schema for resource creation request",
      type: :object,
      properties: %{
        data: Team
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "teams",
          "attributes" => %{
            "title" => "title"
          }
        }
      }
    })
  end

  defmodule UpdateBody do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Team.UpdateBody",
      description: "Request schema body for resource update",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          allOf: [
            Team,
            %Schema{
              type: :object,
              required: [:id]
            }
          ]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "teams",
          "id" => "1",
          "attributes" => %{
            "title" => "title"
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
