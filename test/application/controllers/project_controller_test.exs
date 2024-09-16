defmodule RunaWeb.ProjectControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  @moduletag :projects

  setup do
    team = insert(:team)
    language = insert(:language)

    {:ok, team: team, language: language}
  end

  describe "index endpoint" do
    test "returns list of resources", ctx do
      insert(:project, team: ctx.team)

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
      project = insert(:project, team: ctx.team)

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
      body = %{
        data: %{
          type: "projects",
          attributes: %{
            name: "title"
          },
          relationships: %{
            team: %{
              data: %{
                id: "#{ctx.team.id}",
                type: "teams"
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
      body = %{
        data: %{
          type: "projects",
          attributes: %{},
          relationships: %{
            team: %{
              data: %{
                id: "#{ctx.team.id}",
                type: "teams",
                title: "title"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/projects", body)
      |> json_response(422)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "update endpoint" do
    test "returns resource when data is valid", ctx do
      project = insert(:project, team: ctx.team)

      body = %{
        data: %{
          type: "projects",
          id: "#{project.id}",
          attributes: %{
            name: "title"
          }
        }
      }

      patch(ctx.conn, ~p"/api/projects/#{project.id}", body)
      |> json_response(200)
      |> assert_schema(
        "Project.ShowResponse",
        ctx.spec
      )
    end

    test "renders errors when data is invalid", ctx do
      project = insert(:project, team: ctx.team)

      body = %{
        data: %{
          type: "projects",
          id: "#{project.id}",
          attributes: %{
            name: ""
          }
        }
      }

      patch(ctx.conn, ~p"/api/projects/#{project.id}", body)
      |> json_response(422)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end

    test "renders errors when resource is not found", ctx do
      project = insert(:project, team: ctx.team)

      body = %{
        data: %{
          type: "projects",
          id: "#{project.id}",
          attributes: %{
            name: "title"
          }
        }
      }

      patch(ctx.conn, ~p"/api/projects/1", body)
      |> json_response(404)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "delete endpoint" do
    test "returns no content when resource is deleted", ctx do
      project = insert(:project, team: ctx.team)

      delete(ctx.conn, ~p"/api/projects/#{project.id}")
      |> json_response(204)
    end

    test "returns errors when resource is not found", ctx do
      delete(ctx.conn, ~p"/api/projects/1")
      |> json_response(404)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "relationships endpoint (languages)" do
    test "returns list of associations", ctx do
      project = insert(:project, team: ctx.team)
      insert(:locale, project: project, language: ctx.language)

      response =
        get(ctx.conn, ~p"/api/projects/#{project.id}/relationships/languages")
        |> json_response(200)

      assert_schema(
        response,
        "Document",
        ctx.spec
      )

      Enum.each(
        response["data"],
        &assert_schema(&1, "ResourceIdentifierObject", ctx.spec)
      )
    end

    test "updates resources", ctx do
      project = insert(:project, team: ctx.team)
      language = insert(:language)
      insert(:locale, project: project, language: ctx.language)

      body = %{
        data: [
          %{
            id: "#{language.id}",
            type: "languages"
          }
        ]
      }

      response =
        patch(
          ctx.conn,
          ~p"/api/projects/#{project.id}/relationships/languages",
          body
        )
        |> json_response(200)

      assert_schema(
        response,
        "Document",
        ctx.spec
      )

      assert length(response["data"]) == 1

      relationship = get_in(response, ["data", Access.at(0)])

      assert_schema(
        relationship,
        "ResourceIdentifierObject",
        ctx.spec
      )

      assert relationship["id"] == "#{language.id}"
    end

    test "returns error on update with non-existing association", ctx do
      project = insert(:project, team: ctx.team)

      body = %{
        data: [
          %{
            id: "1",
            type: "languages"
          }
        ]
      }

      patch(
        ctx.conn,
        ~p"/api/projects/#{project.id}/relationships/languages",
        body
      )
      |> json_response(422)
      |> assert_raw_schema(
        resolve_schema(JSONAPI.Schemas.Error, %{}),
        ctx.spec
      )
    end

    test "creates associations", ctx do
      project = insert(:project, team: ctx.team)
      language = insert(:language)

      insert(:locale, project: project, language: ctx.language)

      body = %{
        data: [
          %{
            id: "#{language.id}",
            type: "languages"
          }
        ]
      }

      response =
        post(
          ctx.conn,
          ~p"/api/projects/#{project.id}/relationships/languages",
          body
        )
        |> json_response(201)

      assert length(response["data"]) == 2

      Enum.each(
        response["data"],
        &assert_schema(&1, "ResourceIdentifierObject", ctx.spec)
      )
    end

    test "deletes associations", ctx do
      project = insert(:project, team: ctx.team)
      language = insert(:language)

      insert(:locale, project: project, language: ctx.language)
      insert(:locale, project: project, language: language)

      body = %{
        data: [
          %{
            id: "#{language.id}",
            type: "languages"
          }
        ]
      }

      delete(
        ctx.conn,
        ~p"/api/projects/#{project.id}/relationships/languages",
        body
      )
      |> json_response(204)

      response =
        get(ctx.conn, ~p"/api/projects/#{project.id}/relationships/languages")
        |> json_response(200)

      assert length(response["data"]) == 1
    end
  end
end
