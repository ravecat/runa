defmodule RunaWeb.FileControllerTest do
  use RunaWeb.ConnCase, async: true
  use RunaWeb.APICase

  @moduletag :files

  setup do
    team = insert(:team)

    project =
      insert(:project, base_language: fn -> build(:language) end, team: team)

    {:ok, project: project}
  end

  describe "create endpoint" do
    test "creates new resource", ctx do
      body = %{
        data: %{
          type: "files",
          attributes: %{filename: "name"},
          relationships: %{
            project: %{data: %{id: "#{ctx.project.id}", type: "projects"}}
          }
        }
      }

      post(ctx.conn, ~p"/api/files", body)
      |> json_response(201)
      |> assert_schema("Files.ShowResponse", ctx.spec)
    end
  end
end
