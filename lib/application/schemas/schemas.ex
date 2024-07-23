defmodule RunaWeb.Schemas do
  require OpenApiSpex

  alias OpenApiSpex.Parameter
  alias OpenApiSpex.Schema

  defmodule Meta do
    @moduledoc """
    The schema for meta object.
    """
    OpenApiSpex.schema(%{
      type: :object,
      descrition: "Meta object according to JSON:API specification"
    })
  end

  defmodule Link do
    @moduledoc """
    The schema for link object.
    """
    OpenApiSpex.schema(%{
      description: "A link object representing relationship",
      nullable: true,
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
              description: "A human-readable label for the link's destination"
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
            meta: Meta
          }
        }
      ]
    })
  end

  defmodule Timestamp do
    @moduledoc """
    The schema for timestamp object.
    """
    OpenApiSpex.schema(%{
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
    })
  end

  defmodule ResourceIdentifierObject do
    @moduledoc """
    The schema for resource identifier object.
    """
    OpenApiSpex.schema(%{
      type: :object,
      description: "A resource identifier object",
      oneOf: [
        %Schema{
          type: :object,
          required: [:type, :id],
          properties: %{
            type: %Schema{
              type: :string,
              description: "The type of the resource"
            },
            meta: Meta,
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
            type: %Schema{
              type: :string,
              description: "The type of the resource"
            },
            meta: Meta,
            lid: %Schema{
              type: :string,
              description:
                "A local ID for a new resource to be created on the server. Used instead of 'id' for new resources."
            }
          }
        }
      ]
    })
  end

  defmodule ResourceLinkage do
    @moduledoc """
    The schema for resource linkage object.
    """
    OpenApiSpex.schema(%{
      type: :object,
      description:
        "A resource linkage allows a client to link together all of the included resource objects",
      required: [:data],
      properties: %{
        data: %Schema{
          nullable: true,
          oneOf: [
            ResourceIdentifierObject,
            %Schema{
              type: :array,
              items: ResourceIdentifierObject
            }
          ]
        },
        links: %Schema{
          type: :object,
          minProperties: 1,
          properties: %{
            self: Link,
            related: Link
          },
          additionalProperties: false
        },
        meta: Meta
      }
    })
  end

  defmodule ResourceObject do
    @moduledoc """
    The schema for resource object.
    """
    OpenApiSpex.schema(%{
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
          additionalProperties: ResourceLinkage
        },
        links: %Schema{
          type: :object,
          minProperties: 1,
          properties: %{
            self: Link,
            related: Link
          },
          additionalProperties: false
        },
        meta: Meta
      }
    })
  end

  defmodule Error do
    @moduledoc """
    The schema for error object.
    """
    OpenApiSpex.schema(%{
      type: :object,
      description: "Response schema for failed operation",
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
      required: [:errors]
    })
  end

  defmodule Document do
    @moduledoc """
    The schema for document object.
    """
    OpenApiSpex.schema(%{
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
              minProperties: 1,
              properties: %{
                self: Link,
                first: Link,
                last: Link,
                prev: Link,
                next: Link
              },
              additionalProperties: false
            },
            data: %Schema{
              oneOf: [
                %Schema{
                  type: :object,
                  allOf: [
                    ResourceObject,
                    Timestamp
                  ]
                },
                %Schema{
                  type: :array,
                  items: %Schema{
                    type: :object,
                    allOf: [
                      ResourceObject,
                      Timestamp
                    ]
                  }
                }
              ]
            },
            included: %Schema{
              type: :array,
              items: ResourceObject
            }
          },
          required: [:data],
          additionalProperties: false
        }
      ]
    })
  end

  defmodule Params do
    @moduledoc false

    def path,
      do: %Parameter{
        name: :id,
        in: :path,
        schema: %Schema{type: :integer, minimum: 1},
        description: "Resource ID",
        example: 1,
        required: true
      }

    def query,
      do: [
        %Parameter{
          name: :include,
          in: :query,
          schema: %Schema{
            type: :string,
            pattern: "^[a-zA-Z,.]+(,[a-zA-Z.]+)*$"
          },
          description:
            "Inclusion of related resources using `include=type`. Multiple relationships can be specified by comma-separating them `include=type1,type2`. A server may choose to expose a deeply nested relationship such as `include=type1.type2.type3`.",
          required: false
        },
        %Parameter{
          name: :fields,
          in: :query,
          schema: %Schema{
            type: :object,
            additionalProperties: %Schema{
              type: :string,
              pattern: "^[a-zA-Z]+(,[a-zA-Z]+)*$"
            }
          },
          style: :deepObject,
          description:
            "Sparse fieldsets. Specify fields for each resource type using `fields[type]=field1,field2`. An empty value indicates that no fields should be returned.",
          required: false
        },
        %Parameter{
          name: :sort,
          in: :query,
          schema: %Schema{
            type: :string,
            pattern: "^[-a-zA-Z]+(,-[a-zA-Z]+)*$"
          },
          description:
            "Sorting of resources using `sort=field1,-field2`. A leading `-` indicates descending order.",
          required: false
        },
        %Parameter{
          name: :page,
          in: :query,
          schema: %Schema{
            type: :object,
            properties: %{
              size: %Schema{type: :integer, minimum: 1},
              number: %Schema{type: :integer, minimum: 1},
              offset: %Schema{type: :integer, minimum: 0},
              limit: %Schema{type: :integer, minimum: 1},
              cursor: %Schema{type: :string}
            },
            additionalProperties: false
          },
          style: :deepObject,
          description:
            "Pagination parameters. Supports various pagination strategies.",
          required: false
        }
      ]
  end

  defmodule Headers do
    @moduledoc false

    def accept,
      do: "application/vnd.api+json"

    def content_type,
      do: "application/vnd.api+json"
  end

  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)
    properties = Keyword.fetch!(opts, :properties)

    quote do
      require OpenApiSpex
      alias OpenApiSpex.Schema
      alias RunaWeb.Schemas

      defmodule unquote(Module.concat([name])) do
        @moduledoc """
        The schema for #{unquote(name)} resource
        """
        OpenApiSpex.schema(%{
          allOf: [
            Schemas.ResourceObject,
            %Schema{
              type: :object,
              properties: unquote(properties)
            }
          ]
        })
      end

      defmodule ShowResponse do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(name)}.ShowResponse",
          description: "The schema for resource show response",
          type: :object,
          allOf: [
            Schemas.Document,
            %Schema{
              type: :object,
              properties: %{
                data: %Schema{
                  oneOf: [
                    unquote(Module.concat([name])),
                    %Schema{
                      type: :array,
                      items: unquote(Module.concat([name]))
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
          title: "#{unquote(name)}.IndexResponse",
          description: "The schema for resource index response",
          type: :object,
          allOf: [
            Schemas.Document,
            %Schema{
              type: :object,
              properties: %{
                data: %Schema{
                  type: :array,
                  items: unquote(Module.concat([name]))
                }
              }
            }
          ]
        })
      end

      defmodule CreateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(name)}.CreateBody",
          description: "The body schema for resource creation request",
          type: :object,
          properties: %{
            data: unquote(Module.concat([name]))
          },
          required: [:data]
        })
      end

      defmodule UpdateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(name)}.UpdateBody",
          description: "Request schema body for resource update",
          type: :object,
          properties: %{
            data: %Schema{
              type: :object,
              allOf: [
                unquote(Module.concat([name])),
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
  end
end
