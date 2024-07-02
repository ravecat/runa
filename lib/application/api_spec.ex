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
          "Meta" => %Schema{
            type: :object,
            description:
              "a meta object containing non-standard meta-information"
          },
          "ResourceIdentifierObject" => %Schema{
            type: :object,
            properties: %{
              type: %Schema{
                type: :string,
                description: "The type of the resource"
              },
              meta: %Reference{
                "$ref": "#/components/schemas/Meta"
              }
            },
            oneOf: [
              %Schema{
                type: :object,
                required: [:type, :id],
                properties: %{
                  id: %Schema{
                    type: :string,
                    description:
                      "The ID of the resource. Required except when creating a new resource."
                  }
                }
              },
              %Schema{
                type: :object,
                required: [:type, :lid],
                properties: %{
                  lid: %Schema{
                    type: :string,
                    description:
                      "A local ID for a new resource to be created on the server. Used instead of 'id' for new resources."
                  }
                }
              }
            ],
            required: [:type],
            description: "A resource identifier object"
          },
          "RelationshipObject" => %Schema{
            type: :object,
            description: "A relationship object",
            minProperties: 1,
            properties: %{
              data: %Schema{
                oneOf: [
                  %Reference{
                    "$ref": "#/components/schemas/ResourceIdentifierObject"
                  },
                  %Schema{
                    type: :array,
                    items: %Reference{
                      "$ref": "#/components/schemas/ResourceIdentifierObject"
                    }
                  }
                ]
              },
              links: %Schema{
                type: :object,
                minProperties: 1,
                properties: %{
                  self: %Reference{
                    "$ref": "#/components/schemas/Link"
                  },
                  related: %Reference{
                    "$ref": "#/components/schemas/Link"
                  }
                }
              },
              meta: %Reference{
                "$ref": "#/components/schemas/Meta"
              }
            }
          },
          "Link" => %Schema{
            description: "A link object representing relationship",
            oneOf: [
              %Schema{type: :string, format: :uri},
              %Schema{
                type: :object,
                required: [:href],
                properties: %{
                  href: %Schema{
                    type: :string,
                    format: :uri,
                    description: "A URI-reference pointing to the link's target"
                  },
                  rel: %Schema{
                    type: :string,
                    description: "The link's relation type"
                  },
                  describedby: %Schema{
                    type: :string,
                    format: :uri,
                    description:
                      "A link to a description document for the link target"
                  },
                  title: %Schema{
                    type: :string,
                    description:
                      "A human-readable label for the link's destination"
                  },
                  type: %Schema{
                    type: :string,
                    description: "The media type of the link's target"
                  },
                  hreflang: %Schema{
                    oneOf: [
                      %Schema{type: :string},
                      %Schema{
                        type: :array,
                        items: %Schema{type: :string}
                      }
                    ],
                    description: "The language(s) of the link's target"
                  },
                  meta: %Reference{
                    "$ref": "#/components/schemas/Meta"
                  }
                }
              }
            ]
          },
          "Timestamp" => %Schema{
            type: :object,
            description:
              "an attributes object representing timestamps of creation and update",
            properties: %{
              attributes: %Schema{
                type: :object,
                properties: %{
                  inserted_at: %Schema{
                    type: :string,
                    description: "ISO 8601 date of creation",
                    format: :"date-time"
                  },
                  updated_at: %Schema{
                    type: :string,
                    description: "ISO 8601 date of update",
                    format: :"date-time"
                  },
                  inserted_at_timestamp: %Schema{
                    type: :string,
                    description: "UNIX timestamp of creation",
                    format: :int64,
                    minimum: 0
                  },
                  updated_at_timestamp: %Schema{
                    type: :string,
                    description: "UNIX timestamp of update",
                    format: :int64,
                    minimum: 0
                  }
                },
                required: [
                  :inserted_at,
                  :updated_at,
                  :inserted_at_timestamp,
                  :updated_at_timestamp
                ]
              }
            }
          },
          "ResourceObject" => %Schema{
            type: :object,
            required: [:type],
            additionalProperties: false,
            properties: %{
              type: %Schema{type: :string, description: "Resource type"},
              id: %Schema{type: :string, description: "Resource ID"},
              lid: %Schema{type: :string, description: "Resource local ID"},
              attributes: %Schema{
                type: :object,
                description:
                  "an attributes object representing some of the resource's data"
              },
              relationships: %Schema{
                type: :object,
                description:
                  "a relationships object describing relationships between the resource and other JSON:API resources",
                additionalProperties: %Reference{
                  "$ref": "#/components/schemas/RelationshipObject"
                }
              },
              links: %Schema{
                type: :object,
                description:
                  "a links object containing links related to the resource",
                additionalProperties: %Reference{
                  "$ref": "#/components/schemas/Link"
                }
              },
              meta: %Reference{
                "$ref": "#/components/schemas/Meta"
              }
            }
          },
          "Error" => %Schema{
            description: "Response schema for failed operation",
            type: :object,
            additionalProperties: false,
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
          },
          "Document" => %Schema{
            type: :object,
            oneOf: [
              %Schema{
                type: :object,
                description: "Document schema for empty response",
                properties: %{},
                additionalProperties: false
              },
              %Schema{
                type: :object,
                description: "Document schema for successed operation",
                properties: %{
                  links: %Schema{
                    type: :object,
                    description:
                      "a links object containing links related to the resource",
                    additionalProperties: %Reference{
                      "$ref": "#/components/schemas/Link"
                    }
                  },
                  data: %Schema{
                    oneOf: [
                      %Schema{
                        type: :object,
                        allOf: [
                          %Reference{
                            "$ref": "#/components/schemas/ResourceObject"
                          },
                          %Reference{
                            "$ref": "#/components/schemas/Timestamp"
                          }
                        ]
                      },
                      %Schema{
                        type: :array,
                        items: %Schema{
                          type: :object,
                          allOf: [
                            %Reference{
                              "$ref": "#/components/schemas/ResourceObject"
                            },
                            %Reference{
                              "$ref": "#/components/schemas/Timestamp"
                            }
                          ]
                        }
                      }
                    ]
                  },
                  included: %Schema{
                    type: :array,
                    items: %Schema{
                      type: :object
                    }
                  }
                },
                required: [:data],
                additionalProperties: false
              }
            ]
          }
        },
        responses: %{
          "204" => %Response{
            description: "204 No Content",
            content: %{
              "application/vnd.api+json" => %MediaType{
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
