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
      body = Schema.example(Schemas.TeamPostRequest.schema())

      json =
        post(ctx.conn, ~p"/api/teams", body)
        |> json_response(201)

      assert_schema(json, "TeamResponse", ctx.spec)
    end

    test "renders errors when data is invalid", ctx do
      body =
        Schema.example(Schemas.TeamPostRequest.schema())
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

      body =
        Schema.example(Schemas.TeamPatchRequest.schema())
        |> put_in(["data", "id"], "#{team.id}")

      json =
        patch(ctx.conn, ~p"/api/teams/#{team.id}", body) |> json_response(200)

      assert_schema(json, "TeamResponse", ctx.spec)
    end

    test "returns 404 error when resource doesn't exists", ctx do
      body = Schema.example(Schemas.TeamPatchRequest.schema())

      json =
        patch(ctx.conn, ~p"/api/teams/#{body["data"]["id"]}", body)
        |> json_response(404)

      assert_schema(json, "ErrorResponse", ctx.spec)
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
