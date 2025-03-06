defmodule RunaWeb.Schemas.Translations do
  @moduledoc """
  The file schemas, thats belongs to a project.
  """
  alias OpenApiSpex.Schema

  use RunaWeb.Schema,
    name: "translations",
    schema: %Schema{
      type: :object,
      properties: %{
        attributes: %Schema{
          type: :object,
          properties: %{translation: %Schema{type: :string}}
        }
      }
    }
end
