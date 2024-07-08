defmodule RunaWeb.TeamControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  alias RunaWeb.Schemas.Common, as: CommonSchemas
  alias RunaWeb.Schemas.Teams, as: Schemas

  @moduletag :teams

  describe "index" do
    test "returns list of resources", ctx do
      insert(:team)

      get(ctx.conn, ~p"/api/teams")
      |> json_response(200)
      |> assert_schema(
        "Team.IndexResponse",
        ctx.spec
      )
    end

    test "returns empty list of resources", ctx do
      get(ctx.conn, ~p"/api/teams")
      |> json_response(200)
      |> assert_schema(
        "Team.IndexResponse",
        ctx.spec
      )
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      team = insert(:team)

      get(ctx.conn, ~p"/api/teams/#{team.id}")
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when resource is not found", ctx do
      get(ctx.conn, ~p"/api/teams/1")
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

  describe "create endpoint" do
    test "returns resource when data is valid", ctx do
      body =
        Schema.example(Schemas.CreateBody.schema())
        |> put_in([:data, :attributes, :title], "title")

      post(ctx.conn, ~p"/api/teams", body)
      |> json_response(201)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "renders errors when data is invalid", ctx do
      body = Schema.example(Schemas.CreateBody.schema())

      post(ctx.conn, ~p"/api/teams", body)
      |> json_response(422)
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

  describe "update endpoint" do
    test "returns resource when data is valid", ctx do
      team = insert(:team)

      body =
        Schema.example(Schemas.UpdateBody.schema())
        |> put_in([:data, :id], "#{team.id}")
        |> put_in([:data, :attributes, :title], "title")

      patch(ctx.conn, ~p"/api/teams/#{team.id}", body)
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "returns 404 error when resource doesn't exists", ctx do
      id = "1"

      body =
        Schema.example(Schemas.UpdateBody.schema())
        |> put_in([:data, :id], "1")
        |> put_in([:data, :attributes, :title], "title")

      patch(ctx.conn, ~p"/api/teams/#{id}", body)
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

  describe "delete endpoint" do
    test "deletes resource", ctx do
      team = insert(:team)

      delete(ctx.conn, ~p"/api/teams/#{team.id}")
      |> json_response(204)
      |> assert_raw_schema(
        %Schema{
          oneOf: [
            CommonSchemas.Document
          ]
        },
        ctx.spec
      )
    end
  end
end
