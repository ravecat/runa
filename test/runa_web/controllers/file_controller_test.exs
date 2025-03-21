defmodule RunaWeb.FileControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase
  use RunaWeb.AuthorizedAPIConnCase

  @moduletag :files

  setup do
    team = insert(:team)
    project = insert(:project, team: team)

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
