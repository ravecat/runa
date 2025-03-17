defmodule RunaWeb.Live.Team.ShowTest do
  @moduledoc false
  use RunaWeb.ConnCase, async: true

  @moduletag :teams

  alias Runa.Contributors

  setup ctx do
    team = insert(:team)
    scope = Scope.new(ctx.user)
    owner = insert(:contributor, team: team, user: ctx.user, role: :owner)

    contributors =
      insert_list(3, :contributor,
        team: team,
        user: fn -> insert(:user) end,
        role: :editor
      )

    members = Enum.map(contributors, &{&1.user, &1}) ++ [{owner.user, owner}]

    {:ok, members: members, scope: scope}
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

    test "updates member role", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      Repatch.allow(self(), view.pid)

      Repatch.patch(Runa.Contributors, :update, [mode: :shared], fn _, _, _ ->
        {:ok, %{}}
      end)

      for {member, role} <- ctx.members do
        if role.role != :owner do
          view
          |> element("[aria-label='Member #{member.name} form']")
          |> render_change(%{"contributor" => %{"role" => "admin"}})

          assert Repatch.called?(
                   Runa.Contributors,
                   :update,
                   [%{}, to_string(role.id), %{"role" => "admin"}],
                   by: view.pid
                 )
        end
      end
    end

    test "updates member role based on event", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      Contributors.subscribe(ctx.scope)

      for {member, role} <- ctx.members do
        if role.role != :owner do
          view
          |> element("[aria-label='Member #{member.name} form']")
          |> render_change(%{"contributor" => %{"role" => "admin"}})

          assert_received %Events.ContributorUpdated{}
        end
      end
    end

    test "renders join date", ctx do
      {:ok, view, _} = live(ctx.conn, ~p"/team")

      html = view |> element("[aria-label='Team members']") |> render()

      for {_, role} <- ctx.members do
        assert html =~ format_datetime_to_view(role.inserted_at)
      end
    end
  end
end
