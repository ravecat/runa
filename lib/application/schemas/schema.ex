defmodule RunaWeb.Schema do
  alias OpenApiSpex.Schema
  alias RunaWeb.JSONAPI.Schemas.RelationshipObject
  alias RunaWeb.JSONAPI.Schemas.ResourceIdentifierObject
  alias RunaWeb.JSONAPI.Schemas.ResourceObject

  def validate_schema!(schema) do
    unless is_struct(schema, OpenApiSpex.Schema) do
      raise CompileError,
        description:
          "Invalid schema format: #{inspect(schema)}. Expected a struct of type OpenApiSpex.Schema."
    end
  end

  def validate_name!(name) do
    unless is_atom(name) or is_binary(name) do
      raise CompileError,
        description:
          "Invalid module name format: #{inspect(name)}. Expected an atom or a string."
    end
  end

  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)
    schema = Keyword.fetch!(opts, :schema)

    module_name_str = name |> to_string() |> Macro.camelize()

    module_name =
      module_name_str
      |> List.wrap()
      |> Module.concat()

    quote location: :keep do
      require OpenApiSpex

      alias OpenApiSpex.Schema
      alias RunaWeb.JSONAPI.Schemas.Document
      alias RunaWeb.JSONAPI.Schemas.ResourceObject

      unquote(__MODULE__).validate_name!(unquote(name))
      unquote(__MODULE__).validate_schema!(unquote(schema))

      defmodule unquote(module_name) do
        @moduledoc """
        The schema for #{unquote(module_name_str)} resource
        """
        OpenApiSpex.schema(%{
          allOf: [
            ResourceObject,
            unquote(schema)
          ]
        })
      end

      defmodule ShowResponse do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(module_name_str)}.ShowResponse",
          description: "The schema for resource show response",
          type: :object,
          allOf: [
            Document,
            %Schema{
              type: :object,
              properties: %{
                data: %Schema{
                  oneOf: [
                    unquote(module_name),
                    %Schema{
                      type: :array,
                      items: unquote(module_name)
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
          title: "#{unquote(module_name_str)}.IndexResponse",
          description: "The schema for resource index response",
          type: :object,
          allOf: [
            Document,
            %Schema{
              type: :object,
              properties: %{
                data: %Schema{
                  type: :array,
                  items: unquote(module_name)
                }
              }
            }
          ]
        })
      end

      defmodule CreateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(module_name_str)}.CreateBody",
          description: "The body schema for resource creation request",
          type: :object,
          required: [:data],
          properties: %{
            data: %Schema{
              nullable: true,
              anyOf: [
                ResourceIdentifierObject,
                %Schema{
                  type: :array,
                  items: ResourceIdentifierObject
                },
                %Schema{
                  type: :object,
                  allOf: [
                    unquote(module_name),
                    %Schema{
                      type: :object,
                      required: [:attributes],
                      properties: %{
                        attributes: %Schema{
                          type: :object
                        }
                      }
                    }
                  ]
                },
                %Schema{
                  type: :object,
                  allOf: [
                    unquote(module_name),
                    %Schema{
                      type: :object,
                      required: [:relationships],
                      properties: %{
                        relationships: %Schema{
                          type: :object,
                          additionalProperties: RelationshipObject
                        }
                      }
                    }
                  ]
                },
                %Schema{
                  type: :object,
                  allOf: [
                    unquote(module_name),
                    %Schema{
                      type: :object,
                      required: [:relationships, :attributes],
                      properties: %{
                        relationships: %Schema{
                          type: :object,
                          additionalProperties: RelationshipObject
                        },
                        attributes: %Schema{
                          type: :object
                        }
                      }
                    }
                  ]
                }
              ]
            }
          }
        })
      end

      defmodule UpdateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{unquote(module_name_str)}.UpdateBody",
          description: "Request schema body for resource update",
          type: :object,
          required: [:data],
          properties: %{
            data: %Schema{
              oneOf: [
                ResourceObject,
                ResourceIdentifierObject,
                %Schema{
                  type: :array,
                  items: ResourceIdentifierObject
                }
              ]
            }
          }
        })
      end
    end
  end
end
