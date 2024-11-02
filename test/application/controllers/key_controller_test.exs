defmodule RunaWeb.KeyControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  @moduletag :keys

  setup do
    team = insert(:team)
    project = insert(:project, team: team)

    {:ok, project: project}
  end

  describe "create endpoint" do
    test "creates new resource", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: "name",
            description: "description"
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(201)
      |> assert_schema(
        "Keys.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when required relationships are missing", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: "name",
            description: "description"
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end

    test "returns errors when attributes are invalid", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: nil,
            description: nil
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      key = insert(:key, project: ctx.project)

      get(ctx.conn, ~p"/api/keys/#{key.id}")
      |> json_response(200)
      |> assert_schema(
        "Keys.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when resource is not found", ctx do
      get(ctx.conn, ~p"/api/keys/1")
      |> json_response(404)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end

    test "returns resource with relationships", ctx do
      key = insert(:key, project: ctx.project)

      get(ctx.conn, ~p"/api/keys/#{key.id}")
      |> json_response(200)
      |> get_in(["data", "relationships"])
      |> Enum.each(fn {_, value} ->
        assert_schema(value, "RelationshipObject", ctx.spec)
      end)
    end
  end

  describe "index endpoint" do
    test "returns list of resources", ctx do
      insert(:key, project: ctx.project)

      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> assert_schema(
        "Keys.IndexResponse",
        ctx.spec
      )
    end

    test "returns empty list of resources", ctx do
      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> assert_schema(
        "Keys.IndexResponse",
        ctx.spec
      )
    end

    test "returns list of resources with relationships", ctx do
      insert(:key, project: ctx.project)

      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> get_in(["data", Access.all(), "relationships"])
      |> Enum.flat_map(&Map.values/1)
      |> Enum.each(&assert_schema(&1, "RelationshipObject", ctx.spec))
    end
  end

  describe "update endpoint" do
    test "updates resource", ctx do
      key = insert(:key, project: ctx.project)

      body = %{
        data: %{
          id: "#{key.id}",
          type: "keys",
          attributes: %{
            name: "name",
            description: "description"
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/#{key.id}", body)
      |> json_response(200)
      |> assert_schema(
        "Keys.ShowResponse",
        ctx.spec
      )
    end

    test "returns 404 error when resource doesn't exists", ctx do
      body = %{
        data: %{
          type: "keys",
          id: "1",
          attributes: %{
            name: "name",
            description: "description"
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/1", body)
      |> json_response(404)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end

    test "returns errors when attributes are invalid", ctx do
      key = insert(:key, project: ctx.project)

      body = %{
        data: %{
          id: "#{key.id}",
          type: "keys",
          attributes: %{
            name: nil,
            description: nil
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/#{key.id}", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end
  end

  describe "delete endpoint" do
    test "deletes resource", ctx do
      key = insert(:key, project: ctx.project)

      delete(ctx.conn, ~p"/api/keys/#{key.id}")
      |> json_response(204)
    end

    test "returns error when resource doesn't exists", ctx do
      delete(ctx.conn, ~p"/api/keys/1")
      |> json_response(404)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end
  end
end
