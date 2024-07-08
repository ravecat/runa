defmodule RunaWeb.ProjectControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  alias RunaWeb.Schemas.Common, as: CommonSchemas

  @moduletag :projects

  describe "show endpoint" do
    test "returns resource", ctx do
      team = insert(:team)
      project = insert(:project, team: team)

      get(ctx.conn, ~p"/api/projects/#{project.id}")
      |> json_response(200)
      |> assert_schema(
        "Project.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when resource is not found", ctx do
      get(ctx.conn, ~p"/api/projects/1")
      |> json_response(404)
      |> assert_raw_schema(
        %Schema{
          oneOf: [
            CommonSchemas.Error
          ]
        },
        ctx.spec
      )
    end
  end
end
