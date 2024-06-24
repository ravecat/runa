defmodule RunaWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule Team do
    @moduledoc """
    The schema for team, which are union of users and projects.

    Users related with team are contributors. Projects can be related only with one team.
    Users can be related with many teams.
    """
    OpenApiSpex.schema(%{
      title: "Team",
      description: "Team schema",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "Resource ID"},
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
            },
            inserted_at: %Schema{
              type: :string,
              description: "Creation ISO 8601 date",
              format: :"date-time"
            },
            updated_at: %Schema{
              type: :string,
              description: "Update ISO 8601 date",
              format: :"date-time"
            },
            inserted_at_timestamp: %Schema{
              type: :string,
              description: "Creation UNIX timestamp",
              format: :int64,
              minimum: 0
            },
            updated_at_timestamp: %Schema{
              type: :string,
              description: "Update UNIX timestamp",
              format: :int64,
              minimum: 0
            }
          },
          required: [:title]
        }
      },
      example: %{
        "id" => 1,
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

  defmodule TeamsResponse do
    @moduledoc """
    The schema for team list response.
    """
    OpenApiSpex.schema(%{
      title: "TeamsResponse",
      description: "Response schema for team list",
      type: :object,
      properties: %{
        links: %Schema{
          type: :object,
          properties: %{
            self: %Schema{
              type: :string,
              format: :uri,
              description: "Self link"
            }
          }
        },
        data: %Schema{
          type: :array,
          items: Team
        }
      },
      required: [:links, :data],
      example: %{
        "links" => %{
          "self" => "http://www.example.com/api/teams"
        },
        "data" => [
          %{
            "id" => 1,
            "type" => "teams",
            "attributes" => %{
              "title" => "My awesome team",
              "inserted_at" => "2021-01-01T00:00:00Z",
              "updated_at" => "2021-01-01T00:00:00Z",
              "inserted_at_timestamp" => "1609459200",
              "updated_at_timestamp" => "1609459200"
            }
          }
        ]
      }
    })
  end

  defmodule TeamResponse do
    @moduledoc """
    The schema for team response.
    """
    OpenApiSpex.schema(%{
      title: "TeamResponse",
      description: "Response schema for team",
      type: :object,
      properties: %{
        links: %Schema{
          type: :object,
          properties: %{
            self: %Schema{
              type: :string,
              format: :uri,
              description: "Self link"
            }
          }
        },
        data: Team
      },
      required: [:links, :data],
      example: %{
        "links" => %{
          "self" => "http://www.example.com/api/teams/1"
        },
        "data" => %{
          "id" => 1,
          "type" => "teams",
          "attributes" => %{
            "title" => "My awesome team",
            "inserted_at" => "2021-01-01T00:00:00Z",
            "updated_at" => "2021-01-01T00:00:00Z",
            "inserted_at_timestamp" => "1609459200",
            "updated_at_timestamp" => "1609459200"
          }
        }
      }
    })
  end

  defmodule TeamRequest do
    @moduledoc """
    The schema for team request.
    """
    OpenApiSpex.schema(%{
      title: "TeamRequest",
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

  defmodule ErrorResponse do
    @moduledoc """
    The schema for error response.
    """
    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Response schema for error",
      type: :object,
      properties: %{
        errors: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              status: %Schema{
                type: :string,
                description:
                  "the HTTP status code applicable to this problem, expressed as a string value."
              },
              title: %Schema{
                type: :string,
                description:
                  "a short, human-readable summary of the problem that SHOULD NOT change from occurrence to occurrence of the problem, except for purposes of localization."
              }
            },
            required: [:status, :title]
          }
        }
      },
      required: [:errors],
      example: %{
        "errors" => [
          %{
            "code" => "123",
            "source" => %{"pointer" => "/data/attributes/firstName"},
            "title" => "Value is too short"
          },
          %{
            "code" => "225",
            "source" => %{"pointer" => "/data/attributes/password"},
            "title" =>
              "Passwords must contain a letter, number, and punctuation character."
          },
          %{
            "code" => "226",
            "source" => %{"pointer" => "/data/attributes/password"},
            "title" => "Password and password confirmation do not match."
          }
        ]
      }
    })
  end
end
