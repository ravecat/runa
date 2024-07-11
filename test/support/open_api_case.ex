defmodule RunaWeb.OpenAPICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection and
  JSON API responses.
  """

  defmacro __using__(_) do
    quote do
      import OpenApiSpex.TestAssertions
      import OpenApiSpex

      alias OpenApiSpex.Schema
      alias RunaWeb.APISpec

      setup do
        spec = APISpec.spec()

        {:ok, spec: spec}
      end
    end
  end
end
