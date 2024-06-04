defmodule RunaWeb.TeamControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase

  @moduletag :teams

  import Runa.TeamsFixtures

  describe "API teams" do
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

    test "return empty list of resources", ctx do
      conn = get(ctx.conn, ~p"/api/teams")

      assert %{
               "data" => [],
               "included" => [],
               "links" => %{"self" => "http://www.example.com/api/teams"}
             } == json_response(conn, 200)
    end
  end
end
