defmodule RunaWeb.ProjectControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  alias OpenApiSpex.Schema
  alias RunaWeb.Schemas.Projects, as: OperationSchemas

  @moduletag :projects

  describe "index endpoint" do
    test "returns list of resources", ctx do
      team = insert(:team)
      insert(:project, team: team)

      get(ctx.conn, ~p"/api/projects")
      |> json_response(200)
      |> assert_schema(
        "Project.IndexResponse",
        ctx.spec
      )
    end

    test "returns empty list of resources", ctx do
      get(ctx.conn, ~p"/api/projects")
      |> json_response(200)
      |> assert_schema(
        "Project.IndexResponse",
        ctx.spec
      )
    end
  end

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
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "create endpoint" do
    test "returns resource when data is valid", ctx do
      team = insert(:team)

      body = %{
        data: %{
          type: "projects",
          attributes: %{
            name: "title"
          },
          relationships: %{
            team: %{
              data: %{
                id: "#{team.id}",
                type: "teams",
                title: "title"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/projects", body)
      |> json_response(201)
      |> assert_schema(
        "Project.ShowResponse",
        ctx.spec
      )
    end

    test "renders errors when data is invalid", ctx do
      body = Schema.example(OperationSchemas.CreateBody.schema())

      post(ctx.conn, ~p"/api/projects", body)
      |> json_response(422)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end
  end
end
