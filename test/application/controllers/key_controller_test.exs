defmodule RunaWeb.KeyControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  @moduletag :keys

  setup do
    team = insert(:team)
    project = insert(:project, team: team)

    {:ok, project: project}
  end

  describe "create endpoint" do
    test "creates new resource", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: "name",
            description: "description"
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(201)
      |> assert_schema(
        "Keys.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when relationships are missing", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: "name",
            description: "description"
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end

    test "returns errors when attributes are invalid", ctx do
      body = %{
        data: %{
          type: "keys",
          attributes: %{
            name: nil,
            description: nil
          },
          relationships: %{
            project: %{
              data: %{
                id: "#{ctx.project.id}",
                type: "projects"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/keys", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end
  end
end
