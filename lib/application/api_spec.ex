defmodule RunaWeb.APISpec do
  @moduledoc """
  The OpenAPI specification for the Runa API.
  """
  alias OpenApiSpex.Components
  alias OpenApiSpex.Info
  alias OpenApiSpex.MediaType
  alias OpenApiSpex.OpenApi
  alias OpenApiSpex.Paths
  alias OpenApiSpex.Reference
  alias OpenApiSpex.Response
  alias OpenApiSpex.Schema
  alias OpenApiSpex.SecurityScheme
  alias OpenApiSpex.Server
  alias RunaWeb.Endpoint
  alias RunaWeb.JSONAPI
  alias RunaWeb.Router

  @behaviour OpenApi

  def spec() do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: to_string(Application.spec(:runa, :description)),
        version: to_string(Application.spec(:runa, :vsn))
      },
      paths: Paths.from_router(Router),
      components: %Components{
        securitySchemes: %{
          "ApiKeyAuth" => %SecurityScheme{
            type: "apiKey",
            in: "header",
            name: "X-API-KEY"
          }
        },
        schemas: %{
          "Error" => JSONAPI.Schemas.Error.schema(),
          "Document" => JSONAPI.Schemas.Document.schema(),
          "LinksObject" => JSONAPI.Schemas.LinksObject.schema(),
          "ResourceObject" => JSONAPI.Schemas.ResourceObject.schema(),
          "Timestamp" => JSONAPI.Schemas.Timestamp.schema(),
          "Meta" => JSONAPI.Schemas.Meta.schema(),
          "ResourceLinkage" => JSONAPI.Schemas.ResourceLinkage.schema(),
          "ResourceIdentifierObject" =>
            JSONAPI.Schemas.ResourceIdentifierObject.schema(),
          "RelationshipObject" => JSONAPI.Schemas.RelationshipObject.schema(),
          "Link" => JSONAPI.Schemas.Link.schema()
        },
        responses: %{
          "200" => %Response{
            description: "200 OK",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Document
              }
            }
          },
          "201" => %Response{
            description: "201 Created",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Document
              }
            }
          },
          "204" => %Response{
            description: "204 No Content",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: %Schema{type: :object}
              }
            }
          },
          "400" => %Response{
            description: "400 Bad Request",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "401" => %Response{
            description: "401 Unauthorized",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "403" => %Response{
            description: "403 Forbidden",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "404" => %Response{
            description: "404 Not Found",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "409" => %Response{
            description: "409 Conflict",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "422" => %Response{
            description: "422 Unprocessable Entity",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "500" => %Response{
            description: "500 Internal Server Error",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          }
        }
      },
      security: [
        %{"ApiKeyAuth" => []}
      ]
    }
    |> OpenApiSpex.resolve_schema_modules()
  end

  @type responses :: %{
          (integer | :default) => Response.t() | Reference.t()
        }
  @spec generate_responses(responses) :: responses
  def generate_responses(responses \\ %{}) do
    Map.merge(
      %{
        400 => %Reference{"$ref": "#/components/responses/400"},
        401 => %Reference{"$ref": "#/components/responses/401"},
        403 => %Reference{"$ref": "#/components/responses/403"},
        404 => %Reference{"$ref": "#/components/responses/404"},
        409 => %Reference{"$ref": "#/components/responses/409"},
        422 => %Reference{"$ref": "#/components/responses/422"},
        500 => %Reference{"$ref": "#/components/responses/500"}
      },
      responses
    )
  end
end
