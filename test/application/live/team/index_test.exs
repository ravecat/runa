defmodule RunaWeb.Live.Team.IndexTest do
  @moduledoc false
  use RunaWeb.ConnCase, async: true

  @moduletag :teams

  setup ctx do
    team = insert(:team)

    owner =
      insert(:contributor, team: team, user: ctx.user, role: :owner)

    contributors =
      insert_list(3, :contributor,
        team: team,
        user: fn -> insert(:user) end,
        role: :editor
      )

    members = Enum.map(contributors, &{&1.user, &1})

    {:ok, members: members ++ [{owner.user, owner}]}
  end

  describe "team members table" do
    test "render members name", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {member, _} <- ctx.members do
        assert html =~ member.name
      end
    end

    test "renders member role", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {member, role} <- ctx.members do
        assert Floki.find(html, "tbody tr")
               |> Enum.find(fn row ->
                 Floki.text(row) =~ member.name
               end)
               |> Floki.text() =~ to_string(role.role)
      end
    end

    test "renders join date", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {member, role} <- ctx.members do
        assert Floki.find(html, "tbody tr")
               |> Enum.find(fn row ->
                 Floki.text(row) =~ member.name
               end)
               |> Floki.text() =~ format_datetime_to_view(role.inserted_at)
      end
    end
  end
end
