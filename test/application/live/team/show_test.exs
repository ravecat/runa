defmodule RunaWeb.Live.Team.ShowTest do
  @moduledoc false
  use RunaWeb.ConnCase, async: true

  @moduletag :teams

  setup ctx do
    team = insert(:team)

    owner = insert(:contributor, team: team, user: ctx.user, role: :owner)

    contributors =
      insert_list(3, :contributor,
        team: team,
        user: fn -> insert(:user) end,
        role: :editor
      )

    members = Enum.map(contributors, &{&1.user, &1})

    {:ok, members: members ++ [{owner.user, owner}]}
  end

  describe "team dashboard" do
    test "render members name", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {member, _} <- ctx.members do
        assert html =~ member.name
      end
    end

    test "renders member role", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      for {member, role} <- ctx.members do
        if role.role == :owner do
          assert view
                 |> element("[aria-label='Role for #{member.name}']")
                 |> render() =~ to_string(role.role)
        else
          assert view
                 |> element(
                   "select[aria-label='Role for #{member.name}'] option[selected]"
                 )
                 |> render() =~ to_string(role.role)
        end
      end
    end

    @tag :only
    test "updates member role", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      Repatch.patch(Runa.Contributors, :update, [mode: :shared], fn _, _ ->
        :updated
      end)

      dbg(Runa.Contributors.update(1, 2))

      for {member, role} <- ctx.members do
        dbg(Runa.Contributors.update(1, 2))

        if role.role != :owner do
          view
          |> element("select[aria-label='Role for #{member.name}']")
          |> render_change(%{"role" => "admin"})

          assert Repatch.called?(Runa.Contributors, :update, 2)
        end
      end
    end

    test "renders join date", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {member, role} <- ctx.members do
        assert Floki.find(html, "tbody tr")
               |> Enum.find(fn row -> Floki.text(row) =~ member.name end)
               |> Floki.text() =~ format_datetime_to_view(role.inserted_at)
      end
    end
  end
end
