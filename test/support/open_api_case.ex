defmodule RunaWeb.OpenAPICase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection and
  JSON API responses.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import OpenApiSpex.TestAssertions
    end
  end

  setup_all do
    {:ok, spec: RunaWeb.APISpec.spec()}
  end
end
