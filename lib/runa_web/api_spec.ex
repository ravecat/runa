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
      security: [%{"ApiKeyAuth" => []}],
      servers: [Server.from_endpoint(Endpoint)],
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
            name: JSONAPI.Headers.api_key()
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
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Document
              }
            }
          },
          "201" => %Response{
            description: "201 Created",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Document
              }
            }
          },
          "202" => %Response{
            description: "202 Accepted",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Document
              }
            }
          },
          "204" => %Response{
            description: "204 No Content",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: %Schema{type: :object}
              }
            }
          },
          "400" => %Response{
            description: "400 Bad Request",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "401" => %Response{
            description: "401 Unauthorized",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "403" => %Response{
            description: "403 Forbidden",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "404" => %Response{
            description: "404 Not Found",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "409" => %Response{
            description: "409 Conflict",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          },
          "500" => %Response{
            description: "500 Internal Server Error",
            content: %{
              JSONAPI.Headers.content_type() => %MediaType{
                schema: JSONAPI.Schemas.Error
              }
            }
          }
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end

  @type operation_type :: :index | :show | :create | :update | :delete
  @type responses :: %{(integer | :default) => Response.t() | Reference.t()}
  @spec generate_response_schemas(operation_type(), responses()) :: responses()
  def generate_response_schemas(operation_type, responses \\ %{}) do
    base_responses = %{
      400 => %Reference{"$ref": "#/components/responses/400"},
      401 => %Reference{"$ref": "#/components/responses/401"},
      403 => %Reference{"$ref": "#/components/responses/403"},
      404 => %Reference{"$ref": "#/components/responses/404"},
      500 => %Reference{"$ref": "#/components/responses/500"}
    }

    operation_specific_responses =
      case operation_type do
        :index ->
          Map.merge(base_responses, %{
            200 => %Reference{"$ref": "#/components/responses/200"}
          })

        :show ->
          Map.merge(base_responses, %{
            200 => %Reference{"$ref": "#/components/responses/200"}
          })

        :create ->
          Map.merge(base_responses, %{
            201 => %Reference{"$ref": "#/components/responses/201"},
            202 => %Reference{"$ref": "#/components/responses/202"},
            204 => %Reference{"$ref": "#/components/responses/204"},
            409 => %Reference{"$ref": "#/components/responses/409"}
          })

        :update ->
          Map.merge(base_responses, %{
            200 => %Reference{"$ref": "#/components/responses/200"},
            202 => %Reference{"$ref": "#/components/responses/202"},
            204 => %Reference{"$ref": "#/components/responses/204"},
            409 => %Reference{"$ref": "#/components/responses/409"}
          })

        :delete ->
          Map.merge(base_responses, %{
            200 => %Reference{"$ref": "#/components/responses/200"},
            202 => %Reference{"$ref": "#/components/responses/202"},
            204 => %Reference{"$ref": "#/components/responses/204"}
          })
      end

    Map.merge(operation_specific_responses, responses)
  end
end
