defmodule RunaWeb.Schemas.Teams do
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.Common

  defmodule Team do
    @moduledoc """
    The schema for team, which are union of users and projects.

    Users related with team are contributors. Projects can be related only with one team.
    Users can be related with many teams.
    """
    OpenApiSpex.schema(%{
      allOf: [
        Common.ResourceObject,
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
        Common.Document,
        %Schema{
          type: :object,
          properties: %{
            data: %Schema{
              oneOf: [
                Team,
                %Schema{
                  type: :array,
                  items: Team
                }
              ]
            }
          }
        }
      ]
    })
  end

  defmodule IndexResponse do
    @moduledoc false

    OpenApiSpex.schema(%{
      title: "Team.IndexResponse",
      description: "The schema for resource index response",
      type: :object,
      allOf: [
        Common.Document,
        %Schema{
          type: :object,
          properties: %{
            data: %Schema{
              type: :array,
              items: Team
            }
          }
        }
      ]
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
      required: [:data]
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
      required: [:data]
    })
  end
end
