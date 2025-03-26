defmodule RunaWeb.KeyControllerTest do
  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase
  use RunaWeb.AuthorizedAPIConnCase

  @moduletag :keys

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)

    {:ok, localization_file: file}
  end

  describe "create endpoint" do
    test "creates new resource", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{name: "name", description: "description"},
          relationships: %{
            file: %{data: %{id: "#{ctx.localization_file.id}", type: "files"}}
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(201)
      |> assert_schema("Keys.ShowResponse", ctx.spec)
    end

    test "returns errors when required relationships are missing", ctx do
      body = %{data: %{type: "keys", attributes: %{description: "description"}}}

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns errors when attributes are invalid", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{name: nil, description: nil},
          relationships: %{
            file: %{data: %{id: "#{ctx.localization_file.id}", type: "files"}}
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      key = insert(:key, file: ctx.localization_file)

      get(ctx.conn, ~p"/api/keys/#{key.id}")
      |> json_response(200)
      |> assert_schema("Keys.ShowResponse", ctx.spec)
    end

    test "returns errors when resource is not found", ctx do
      get(ctx.conn, ~p"/api/keys/1")
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns resource with relationships", ctx do
      key = insert(:key, file: ctx.localization_file)

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
      insert(:key, file: ctx.localization_file)

      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> assert_schema("Keys.IndexResponse", ctx.spec)
    end

    test "returns empty list of resources", ctx do
      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> assert_schema("Keys.IndexResponse", ctx.spec)
    end

    test "returns list of resources with relationships", ctx do
      insert(:key, file: ctx.localization_file)

      get(ctx.conn, ~p"/api/keys")
      |> json_response(200)
      |> get_in(["data", Access.all(), "relationships"])
      |> Enum.flat_map(&Map.values/1)
      |> Enum.each(&assert_schema(&1, "RelationshipObject", ctx.spec))
    end
  end

  describe "update endpoint" do
    test "updates resource", ctx do
      key = insert(:key, file: ctx.localization_file)

      body = %{
        data: %{
          id: "#{key.id}",
          type: "keys",
          attributes: %{name: "name", description: "description"},
          relationships: %{
            file: %{data: %{id: "#{ctx.localization_file.id}", type: "files"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/#{key.id}", body)
      |> json_response(200)
      |> assert_schema("Keys.ShowResponse", ctx.spec)
    end

    test "returns 404 error when resource doesn't exists", ctx do
      body = %{
        data: %{
          type: "keys",
          id: "1",
          attributes: %{name: "name", description: "description"},
          relationships: %{
            file: %{data: %{id: "#{ctx.localization_file.id}", type: "files"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/1", body)
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns errors when attributes are invalid", ctx do
      key = insert(:key, file: ctx.localization_file)

      body = %{
        data: %{
          id: "#{key.id}",
          type: "keys",
          attributes: %{name: nil, description: nil},
          relationships: %{
            file: %{data: %{id: "#{ctx.localization_file.id}", type: "files"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/keys/#{key.id}", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end
  end

  describe "delete endpoint" do
    test "deletes resource", ctx do
      key = insert(:key, file: ctx.localization_file)

      delete(ctx.conn, ~p"/api/keys/#{key.id}")
      |> json_response(204)
    end

    test "returns error when resource doesn't exists", ctx do
      delete(ctx.conn, ~p"/api/keys/1")
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end
  end
end
