defmodule RunaWeb.TeamControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase
  alias RunaWeb.Schemas

  @moduletag :teams

  import Runa.Factory

  describe "index" do
    test "returns list of resources", ctx do
      insert(:team)
      json = get(ctx.conn, ~p"/api/teams") |> json_response(200)

      assert_schema(json, "TeamsResponse", ctx.spec)
    end

    test "returns empty list of resources", ctx do
      json = get(ctx.conn, ~p"/api/teams") |> json_response(200)

      assert_schema(json, "TeamsResponse", ctx.spec)
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      team = insert(:team)
      json = get(ctx.conn, ~p"/api/teams/#{team.id}") |> json_response(200)

      assert_schema(json, "TeamResponse", ctx.spec)
    end

    test "returns errors when resource is not found", ctx do
      json = get(ctx.conn, ~p"/api/teams/1") |> json_response(404)

      assert_schema(json, "ErrorResponse", ctx.spec)
    end
  end

  describe "create endpoint" do
    test "returns resource when data is valid", ctx do
      body = Schema.example(Schemas.TeamRequest.schema())

      json =
        post(ctx.conn, ~p"/api/teams", body)
        |> json_response(201)

      assert_schema(json, "TeamResponse", ctx.spec)
    end

    test "renders errors when data is invalid", ctx do
      body =
        Schema.example(Schemas.TeamRequest.schema())
        |> put_in(["data", "attributes"], %{})

      json =
        post(ctx.conn, ~p"/api/teams", body)
        |> json_response(422)

      assert_schema(json, "ErrorResponse", ctx.spec)
    end
  end

  describe "update endpoint" do
    test "returns resource when data is valid", ctx do
      team = insert(:team)

      conn =
        patch(ctx.conn, ~p"/api/teams/#{team.id}", %{
          "data" => %{
            "type" => "teams",
            "id" => "#{team.id}",
            "attributes" => %{
              "title" => "New team title"
            }
          }
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "inserted_at" => _,
                   "inserted_at_timestamp" => _,
                   "title" => "New team title",
                   "updated_at" => _,
                   "updated_at_timestamp" => _
                 },
                 "id" => id,
                 "type" => "teams",
                 "relationships" => %{},
                 "links" => %{"self" => _}
               },
               "included" => [],
               "links" => %{"self" => _}
             } = json_response(conn, 200)

      conn = get(ctx.conn, ~p"/api/teams/#{id}")

      assert %{
               "data" => %{
                 "attributes" => %{
                   "inserted_at" => _,
                   "inserted_at_timestamp" => _,
                   "title" => "New team title",
                   "updated_at" => _,
                   "updated_at_timestamp" => _
                 },
                 "id" => _,
                 "type" => "teams",
                 "relationships" => %{},
                 "links" => %{"self" => _}
               },
               "included" => [],
               "links" => %{"self" => _}
             } = json_response(conn, 200)
    end

    test "returns 404 error when resource doesn't exists", ctx do
      conn =
        patch(ctx.conn, ~p"/api/teams/1", %{
          "data" => %{
            "type" => "teams",
            "id" => "1",
            "attributes" => %{
              "title" => "New team title"
            }
          }
        })

      assert %{
               "errors" => [
                 %{
                   "title" => "Not Found",
                   "detail" => "Not Found",
                   "status" => "404"
                 }
               ]
             } = json_response(conn, 404)
    end
  end

  describe "delete endpoint" do
    test "deletes resource", ctx do
      team = insert(:team)
      conn = delete(ctx.conn, ~p"/api/teams/#{team.id}")

      assert %{
               "meta" => %{
                 "message" => "Resource deleted"
               }
             } = json_response(conn, 204)
    end
  end
end
