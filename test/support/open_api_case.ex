defmodule RunaWeb.OpenAPICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection and
  JSON API responses.
  """
  defmacro __using__(_) do
    quote do
      import OpenApiSpex.TestAssertions

      alias OpenApiSpex.Reference
      alias OpenApiSpex.Schema
      alias RunaWeb.APISpec

      setup do
        spec = APISpec.spec()

        {:ok, spec: spec}
      end

      def assert_response(value, schema, spec) do
        assert_raw_schema(
          value,
          %Schema{
            oneOf: [
              %Reference{"$ref": "#/components/schemas/Error"},
              %Schema{
                allOf: [
                  %Reference{"$ref": "#/components/schemas/Document"},
                  schema
                ]
              }
            ]
          },
          spec
        )
      end

      def assert_response(value, spec) do
        assert_raw_schema(
          value,
          %Schema{
            oneOf: [
              %Reference{"$ref": "#/components/schemas/Error"},
              %Reference{"$ref": "#/components/schemas/Document"}
            ]
          },
          spec
        )
      end
    end
  end
end
