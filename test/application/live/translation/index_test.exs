defmodule RunaWeb.Live.Translation.IndexTest do
  use RunaWeb.ConnCase, async: true

  @moduletag :translations

  import RunaWeb.Formatters

  setup do
    team = insert(:team)
    project = insert(:project, team: team)
    file = insert(:file, project: project)
    keys = insert_list(2, :key, file: file)

    {:ok, keys: keys, project: project}
  end

  describe "translations view" do
    test "renders localization keys", ctx do
      {:ok, view, _} =
        live(
          ctx.conn,
          ~p"/projects/#{ctx.project.id}?section=translations"
        )

      for key <- ctx.keys do
        assert render(view) =~ key.name
      end
    end

    test "renders the number of keys", ctx do
      {:ok, view, _} =
        live(
          ctx.conn,
          ~p"/projects/#{ctx.project.id}?section=translations"
        )

      assert render(view) =~ "#{length(ctx.keys)} keys"
    end

    test "renders the latest translations activity", ctx do
      {:ok, view, _} =
        live(
          ctx.conn,
          ~p"/projects/#{ctx.project.id}?section=translations"
        )

      for key <- ctx.keys do
        assert view
               |> element("[aria-label='Latest #{key.name} activity']")
               |> render() =~ format_datetime_to_view(key.updated_at)
      end
    end
  end
end
