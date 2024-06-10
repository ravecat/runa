defmodule RunaWeb.TeamControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase

  @moduletag :teams

  import Runa.TeamsFixtures

  describe "index" do
    test "returns list of resources", ctx do
      team = create_aux_team()
      conn = get(ctx.conn, ~p"/api/teams")

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "inserted_at" => _,
                     "inserted_at_timestamp" => _,
                     "title" => title,
                     "updated_at" => _,
                     "updated_at_timestamp" => _
                   },
                   "id" => id,
                   "type" => "teams",
                   "relationships" => %{},
                   "links" => %{"self" => _}
                 }
               ],
               "included" => [],
               "links" => %{"self" => _}
             } = json_response(conn, 200)

      assert title == team.title
      assert id == team.id |> Integer.to_string()
    end

    test "returns empty list of resources", ctx do
      conn = get(ctx.conn, ~p"/api/teams")

      assert %{
               "data" => [],
               "included" => [],
               "links" => %{"self" => "http://www.example.com/api/teams"}
             } == json_response(conn, 200)
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      team = create_aux_team()
      conn = get(ctx.conn, ~p"/api/teams/#{team.id}")

      assert %{
               "data" => %{
                 "attributes" => %{
                   "inserted_at" => _,
                   "inserted_at_timestamp" => _,
                   "title" => title,
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

      assert title == team.title
      assert id == team.id |> Integer.to_string()
    end

    test "returns errors when resource is not found", ctx do
      conn = get(ctx.conn, ~p"/api/teams/1")

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

  describe "create endpoint" do
    test "returns resource when data is valid", ctx do
      conn =
        post(ctx.conn, ~p"/api/teams", %{
          "data" => %{
            "type" => "teams",
            "attributes" => %{
              "title" => "Team 1"
            }
          }
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "inserted_at" => _,
                   "inserted_at_timestamp" => _,
                   "title" => "Team 1",
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
             } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", ctx do
      conn =
        post(ctx.conn, ~p"/api/teams", %{
          "data" => %{
            "type" => "teams",
            "attributes" => %{}
          }
        })

      assert %{
               "errors" => [
                 %{
                   "source" => %{"pointer" => "/data/attributes/title"},
                   "title" => "title can't be blank"
                 }
               ]
             } == json_response(conn, 422)
    end
  end

  describe "update endpoint" do
    test "returns resource when data is valid", ctx do
      team = create_aux_team()

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
                 "id" => id,
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

  # describe "delete team" do
  #   setup [:create_team]

  #   test "deletes chosen team", %{conn: conn, team: team} do
  #     conn = delete(conn, ~p"/api/teams/#{team}")
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, ~p"/api/teams/#{team}")
  #     end
  #   end
  # end
end
