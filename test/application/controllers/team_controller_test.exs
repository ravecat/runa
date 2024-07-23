defmodule RunaWeb.TeamControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  alias RunaWeb.Schemas

  @moduletag :teams

  describe "index endpoint" do
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
        resolve_schema(Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "create endpoint" do
    test "returns resource when data is valid", ctx do
      body =
        Schema.example(Schemas.Teams.CreateBody.schema())
        |> put_in([:data, :attributes, :title], "title")

      post(ctx.conn, ~p"/api/teams", body)
      |> json_response(201)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "renders errors when data is invalid", ctx do
      body = Schema.example(Schemas.Teams.CreateBody.schema())

      post(ctx.conn, ~p"/api/teams", body)
      |> json_response(422)
      |> assert_raw_schema(
        resolve_schema(Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "update endpoint" do
    test "returns resource when data is valid", ctx do
      team = insert(:team)

      body =
        Schema.example(Schemas.Teams.UpdateBody.schema())
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
      body =
        Schema.example(Schemas.Teams.UpdateBody.schema())
        |> put_in([:data, :id], "1")
        |> put_in([:data, :attributes, :title], "title")

      patch(ctx.conn, ~p"/api/teams/1", body)
      |> json_response(404)
      |> assert_raw_schema(
        resolve_schema(Schemas.Error, %{}),
        ctx.spec
      )
    end
  end

  describe "delete endpoint" do
    test "deletes resource", ctx do
      team = insert(:team)

      delete(ctx.conn, ~p"/api/teams/#{team.id}")
      |> json_response(204)
      |> assert_schema(
        "Document",
        ctx.spec
      )
    end
  end

  describe "inclusion endpoint" do
    test "returns related resources for entity", ctx do
      team = insert(:team)
      insert(:project, team: team)

      get(ctx.conn, ~p"/api/teams/#{team.id}?include=projects")
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "returns empty list if entity hasn't related resources", ctx do
      team = insert(:team)

      response =
        get(ctx.conn, ~p"/api/teams/#{team.id}?include=projects")
        |> json_response(200)

      assert_schema(
        response,
        "Team.ShowResponse",
        ctx.spec
      )

      assert response["included"] == []
    end

    test "returns empty list if entities haven't related resources", ctx do
      response =
        get(ctx.conn, ~p"/api/teams?include=projects")
        |> json_response(200)

      assert_schema(
        response,
        "Team.ShowResponse",
        ctx.spec
      )

      assert response["included"] == []
    end

    test "returns related resources for entities", ctx do
      team = insert(:team)
      insert(:project, team: team)

      get(ctx.conn, ~p"/api/teams?include=projects")
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "returns sparse fieldset for entity", ctx do
      team = insert(:team)
      insert(:project, team: team)

      get(
        ctx.conn,
        ~p"/api/teams/#{team.id}?include=projects&fields[projects]=name"
      )
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end

    test "handles deeply nested relationship", ctx do
      team = insert(:team)
      project = insert(:project, team: team)
      insert(:key, project: project)

      get(
        ctx.conn,
        ~p"/api/teams/#{team.id}?include=projects.keys"
      )
      |> json_response(200)
      |> assert_schema(
        "Team.ShowResponse",
        ctx.spec
      )
    end
  end

  describe "sorting endpoint" do
    test "returns sorted resources", ctx do
      insert_pair(:team)

      get(ctx.conn, ~p"/api/teams?sort=title")
      |> json_response(200)
      |> assert_schema(
        "Team.IndexResponse",
        ctx.spec
      )
    end

    test "returns asc/desc sorted resources", ctx do
      insert_pair(:team)

      asc = get(ctx.conn, ~p"/api/teams?sort=title") |> json_response(200)

      desc = get(ctx.conn, ~p"/api/teams?sort=-title") |> json_response(200)

      assert List.first(asc["data"]) == List.last(desc["data"])
      assert List.last(asc["data"]) == List.first(desc["data"])
    end
  end

  describe "filtering endpoint" do
    test "returns filtered resources", ctx do
      %{title: title} = insert(:team, title: "resource1")
      insert(:team, title: "resource2")

      response =
        get(ctx.conn, ~p"/api/teams?filter[title]=#{title}")
        |> json_response(200)

      assert_schema(
        response,
        "Team.IndexResponse",
        ctx.spec
      )

      assert match?(
               %{"data" => [%{"attributes" => %{"title" => ^title}}]},
               response
             )

      assert length(response["data"]) == 1
    end
  end

  describe "pagination endpoint" do
    test "returns paginated resources", ctx do
      insert_list(5, :team)

      size = 2

      response =
        get(ctx.conn, ~p"/api/teams?page[number]=1&page[size]=#{size}")
        |> json_response(200)

      assert_schema(
        response,
        "Team.IndexResponse",
        ctx.spec
      )
    end

    test "return paginated resources with required links", ctx do
      insert_list(5, :team)

      size = 2

      response =
        get(ctx.conn, ~p"/api/teams?page[number]=1&page[size]=#{size}")
        |> json_response(200)

      assert %{
               "links" => %{
                 "first" => first,
                 "last" => last,
                 "next" => next,
                 "self" => self
               }
             } = response

      assert Enum.all?(
               [first, last, next, self],
               &(is_binary(&1) or is_nil(&1))
             )
    end

    test "returns paginated resources with required length", ctx do
      insert_list(5, :team)

      size = 2

      response =
        get(ctx.conn, ~p"/api/teams?page[number]=1&page[size]=#{size}")
        |> json_response(200)

      assert length(response["data"]) == size
    end
  end
end
