defmodule RunaWeb.APISpec do
  @moduledoc """
  The OpenAPI specification for the Runa API.
  """
  alias OpenApiSpex.Components
  alias OpenApiSpex.Info
  alias OpenApiSpex.MediaType
  alias OpenApiSpex.OpenApi
  alias OpenApiSpex.Paths
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
        responses: %{
          "204" => %Response{
            description: "204 No Content",
            content: %{
              JSONAPI.Schemas.Headers.content_type() => %MediaType{
                schema: %Schema{type: :object}
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
end
