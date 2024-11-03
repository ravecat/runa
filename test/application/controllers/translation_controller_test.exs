defmodule RunaWeb.TranslationControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase

  @moduletag :translations

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    key = insert(:key, project: project)
    language = insert(:language)

    {:ok, key: key, language: language}
  end

  describe "create endpoint" do
    test "creates resource", ctx do
      body = %{
        data: %{
          type: "translations",
          attributes: %{
            translation: "translation content"
          },
          relationships: %{
            key: %{
              data: %{
                id: "#{ctx.key.id}",
                type: "keys"
              }
            },
            language: %{
              data: %{
                id: "#{ctx.language.id}",
                type: "languages"
              }
            }
          }
        }
      }

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(201)
      |> assert_schema(
        "Translations.ShowResponse",
        ctx.spec
      )
    end

    test "returns errors when required attributes are missing", ctx do
      body = %{
        data: %{
          type: "translations",
          attributes: %{
            translation: nil
          }
        }
      }

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end

    test "returns errors when required relationships are missing", ctx do
      body = %{
        data: %{
          type: "translations",
          attributes: %{
            content: "translation content"
          }
        }
      }

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(422)
      |> assert_schema(
        "Error",
        ctx.spec
      )
    end
  end
end
