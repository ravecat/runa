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

  describe "show" do
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

    test "returns error when resource is not found", ctx do
      conn = get(ctx.conn, ~p"/api/teams/1")

      assert %{
               "errors" => [
                 %{
                   "title" => "Not Found",
                   "detail" => "Not Found",
                   "code" => "404"
                 }
               ]
             } = json_response(conn, 404)
    end
  end

  describe "create" do
    test "returns team when data is valid", ctx do
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

  # describe "update team" do
  #   setup [:create_team]
  #   test "renders team when data is valid", %{
  #     conn: conn,
  #     team: %Team{id: id} = team
  #   } do
  #     conn = put(conn, ~p"/api/teams/#{team}", team: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, ~p"/api/teams/#{id}")

  #     assert %{
  #              "id" => ^id
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, team: team} do
  #     conn = put(conn, ~p"/api/teams/#{team}", team: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

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
