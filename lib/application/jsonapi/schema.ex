defmodule RunaWeb.Schema do
  @moduledoc """
  Macros for generating JSON:API schemas.

  Resulted schemas include to the current module and represent a Open API schema for the resource.

  ## Examples

  ```elixir
  defmodule MySchema do
    use RunaWeb.Schema, name: "MySchema", schema: %Schema{
      type: :object,
      properties: %{
        name: %Schema{
          type: :string
        }
      }
    }
  end
  ```
  """
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
    unless is_binary(name) do
      raise CompileError,
        description:
          "Invalid module name format: #{inspect(name)}. Expected a string."
    end
  end

  @spec __using__(Keyword.t(name: String.t(), schema: Schema.t())) :: Macro.t()
  defmacro __using__(opts) do
    name = Keyword.fetch!(opts, :name)
    schema = Keyword.fetch!(opts, :schema)
    module = Module.concat([Macro.camelize(name)])

    quote location: :keep do
      require OpenApiSpex

      alias OpenApiSpex.Schema
      alias RunaWeb.JSONAPI.Schemas.Document
      alias RunaWeb.JSONAPI.Schemas.ResourceObject

      unquote(__MODULE__).validate_name!(unquote(name))
      unquote(__MODULE__).validate_schema!(unquote(schema))

      unquote(generate_main_schema(module, schema))
      unquote(generate_show_response(module))
      unquote(generate_index_response(module))
      unquote(generate_create_body(module))
      unquote(generate_update_body(module))
    end
  end

  defp generate_main_schema(module, schema) do
    quote do
      defmodule unquote(module) do
        OpenApiSpex.schema(%{allOf: [ResourceObject, unquote(schema)]})
      end
    end
  end

  defp generate_show_response(module) do
    quote do
      defmodule ShowResponse do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{inspect(unquote(module))}.ShowResponse",
          description: "The schema for resource show response",
          type: :object,
          allOf: [
            Document,
            %Schema{
              type: :object,
              properties: %{
                data: %Schema{
                  oneOf: [
                    unquote(module),
                    %Schema{type: :array, items: unquote(module)}
                  ]
                }
              }
            }
          ]
        })
      end
    end
  end

  defp generate_index_response(module) do
    quote do
      defmodule IndexResponse do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{inspect(unquote(module))}.IndexResponse",
          description: "The schema for resource index response",
          type: :object,
          allOf: [
            Document,
            %Schema{
              type: :object,
              properties: %{data: %Schema{type: :array, items: unquote(module)}}
            }
          ]
        })
      end
    end
  end

  defp generate_create_body(module) do
    quote do
      defmodule CreateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{inspect(unquote(module))}.CreateBody",
          description: "The body schema for resource creation request",
          type: :object,
          required: [:data],
          properties: %{
            data: %Schema{
              nullable: true,
              anyOf: unquote(create_body_schemas(module))
            }
          }
        })
      end
    end
  end

  defp create_body_schemas(module) do
    quote do
      [
        ResourceIdentifierObject,
        %Schema{type: :array, items: ResourceIdentifierObject},
        %Schema{
          type: :object,
          allOf: [
            unquote(module),
            %Schema{
              type: :object,
              required: [:attributes],
              properties: %{attributes: %Schema{type: :object}}
            }
          ]
        },
        %Schema{
          type: :object,
          allOf: [
            unquote(module),
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
            unquote(module),
            %Schema{
              type: :object,
              required: [:relationships, :attributes],
              properties: %{
                relationships: %Schema{
                  type: :object,
                  additionalProperties: RelationshipObject
                },
                attributes: %Schema{type: :object}
              }
            }
          ]
        }
      ]
    end
  end

  defp generate_update_body(module) do
    quote do
      defmodule UpdateBody do
        @moduledoc false
        OpenApiSpex.schema(%{
          title: "#{inspect(unquote(module))}.UpdateBody",
          description: "Request schema body for resource update",
          type: :object,
          required: [:data],
          properties: %{
            data: %Schema{
              oneOf: [
                ResourceObject,
                ResourceIdentifierObject,
                %Schema{type: :array, items: ResourceIdentifierObject}
              ]
            }
          }
        })
      end
    end
  end
end
