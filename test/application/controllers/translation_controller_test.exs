defmodule RunaWeb.TranslationControllerTest do
  @moduledoc false

  use RunaWeb.ConnCase, async: true
  use RunaWeb.JSONAPICase
  use RunaWeb.OpenAPICase
  use RunaWeb.VerifiedConnCase

  @moduletag :translations

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)
    key = insert(:key, file: file)
    language = insert(:language)

    {:ok, key: key, language: language}
  end

  describe "create endpoint" do
    test "creates resource", ctx do
      body = %{
        data: %{
          type: "translations",
          attributes: %{translation: "translation content"},
          relationships: %{
            key: %{data: %{id: "#{ctx.key.id}", type: "keys"}},
            language: %{data: %{id: "#{ctx.language.id}", type: "languages"}}
          }
        }
      }

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(201)
      |> assert_schema("Translations.ShowResponse", ctx.spec)
    end

    test "returns errors when required attributes are missing", ctx do
      body = %{data: %{type: "translations", attributes: %{translation: nil}}}

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns errors when required relationships are missing", ctx do
      body = %{
        data: %{
          type: "translations",
          attributes: %{content: "translation content"}
        }
      }

      post(ctx.conn, ~p"/api/translations", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end
  end

  describe "show endpoint" do
    test "returns resource", ctx do
      translation = insert(:translation, key: ctx.key, language: ctx.language)

      get(ctx.conn, ~p"/api/translations/#{translation.id}")
      |> json_response(200)
      |> assert_schema("Translations.ShowResponse", ctx.spec)
    end

    test "returns errors when resource is not found", ctx do
      get(ctx.conn, ~p"/api/translations/1")
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns resource with relationships", ctx do
      translation = insert(:translation, key: ctx.key, language: ctx.language)

      get(ctx.conn, ~p"/api/translations/#{translation.id}")
      |> json_response(200)
      |> get_in(["data", "relationships"])
      |> Enum.each(fn {_, value} ->
        assert_schema(value, "RelationshipObject", ctx.spec)
      end)
    end
  end

  describe "update endpoint" do
    test "updates resource", ctx do
      translation = insert(:translation, key: ctx.key, language: ctx.language)

      body = %{
        data: %{
          id: "#{translation.id}",
          type: "translations",
          attributes: %{translation: "updated translation content"},
          relationships: %{
            key: %{data: %{id: "#{ctx.key.id}", type: "keys"}},
            language: %{data: %{id: "#{ctx.language.id}", type: "languages"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/translations/#{translation.id}", body)
      |> json_response(200)
      |> assert_schema("Translations.ShowResponse", ctx.spec)

      get(ctx.conn, ~p"/api/translations/#{translation.id}")
      |> json_response(200)
      |> get_in(["data", "attributes", "translation"])
      |> assert("updated translation content")
    end

    test "returns 404 error when resource doesn't exists", ctx do
      body = %{
        data: %{
          type: "translations",
          id: "1",
          attributes: %{translation: "updated translation content"},
          relationships: %{
            key: %{data: %{id: "#{ctx.key.id}", type: "keys"}},
            language: %{data: %{id: "#{ctx.language.id}", type: "languages"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/translations/1", body)
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end

    test "returns errors when attributes are invalid", ctx do
      translation = insert(:translation, key: ctx.key, language: ctx.language)

      body = %{
        data: %{
          id: "#{translation.id}",
          type: "translations",
          attributes: %{translation: nil},
          relationships: %{
            key: %{data: %{id: "#{ctx.key.id}", type: "keys"}},
            language: %{data: %{id: "#{ctx.language.id}", type: "languages"}}
          }
        }
      }

      patch(ctx.conn, ~p"/api/translations/#{translation.id}", body)
      |> json_response(409)
      |> assert_schema("Error", ctx.spec)
    end
  end

  describe "delete endpoint" do
    test "deletes resource", ctx do
      translation = insert(:translation, key: ctx.key, language: ctx.language)

      delete(ctx.conn, ~p"/api/translations/#{translation.id}")
      |> json_response(204)

      get(ctx.conn, ~p"/api/translations/#{translation.id}")
      |> json_response(404)
    end

    test "returns error when resource doesn't exists", ctx do
      delete(ctx.conn, ~p"/api/translations/1")
      |> json_response(404)
      |> assert_schema("Error", ctx.spec)
    end
  end
end
