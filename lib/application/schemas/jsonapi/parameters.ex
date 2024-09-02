defmodule RunaWeb.Schemas.JSONAPI.Parameters do
  @moduledoc false
  alias OpenApiSpex.Parameter
  alias OpenApiSpex.Schema

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
