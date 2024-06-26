defmodule RunaWeb.Schemas do
  require OpenApiSpex

  alias OpenApiSpex.Reference
  alias OpenApiSpex.Schema

  defmodule Team do
    @moduledoc """
    The schema for team, which are union of users and projects.

    Users related with team are contributors. Projects can be related only with one team.
    Users can be related with many teams.
    """
    OpenApiSpex.schema(%{
      description: "Team",
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
      ],
      example: %{
        "type" => "teams",
        "attributes" => %{
          "title" => "My awesome team",
          "inserted_at" => "2021-01-01T00:00:00Z",
          "updated_at" => "2021-01-01T00:00:00Z",
          "inserted_at_timestamp" => "1609459200",
          "updated_at_timestamp" => "1609459200"
        }
      }
    })
  end

  defmodule TeamPostRequest do
    @moduledoc """
    The schema for team request.
    """
    OpenApiSpex.schema(%{
      title: "TeamPostRequest",
      description: "Request schema for team",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{
              type: :string,
              description: "Resource type"
            },
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
          },
          required: [:type, :attributes]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "teams",
          "attributes" => %{
            "title" => "My awesome team"
          }
        }
      }
    })
  end

  defmodule TeamPatchRequest do
    @moduledoc """
    The schema for team request.
    """
    OpenApiSpex.schema(%{
      title: "TeamPatchRequest",
      description: "Request schema for team",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            type: %Schema{
              type: :string,
              description: "Resource type"
            },
            id: %Schema{
              type: :string,
              description: "Resource ID"
            },
            attributes: %Schema{
              type: :object,
              properties: %{
                title: %Schema{
                  type: :string,
                  description: "Team title",
                  pattern: ~r/[a-zA-Z][a-zA-Z0-9_\s]+/
                }
              }
            }
          },
          required: [:type, :id, :attributes]
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "type" => "teams",
          "id" => "1",
          "attributes" => %{
            "title" => "My awesome team"
          }
        }
      }
    })
  end
end
