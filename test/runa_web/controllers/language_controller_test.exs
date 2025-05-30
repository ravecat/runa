defmodule RunaWeb.LanguageControllerTest do
  use RunaWeb.ConnCase, async: true
  use RunaWeb.APICase

  @moduletag :languages

  describe "index endpoint" do
    test "returns list of resources", ctx do
      insert(:language)

      get(ctx.conn, ~p"/api/languages")
      |> json_response(200)
      |> assert_schema("Language.IndexResponse", ctx.spec)
    end

    test "returns empty list of resources", ctx do
      get(ctx.conn, ~p"/api/languages")
      |> json_response(200)
      |> assert_schema("Language.IndexResponse", ctx.spec)
    end
  end
end
