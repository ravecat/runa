defmodule RunaWeb.Live.Team.ShowTest do
  use RunaWeb.FeatureCase, auth: true

  import RunaWeb.Adapters.DateTime

  @moduletag :teams

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
    feature "renders member name", ctx do
      session =
        visit(ctx.session, "/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      for {member, _} <- ctx.members do
        assert_has(
          session,
          Query.css("[aria-label=\"Member #{member.name} form\"]",
            text: member.name
          )
        )
      end
    end

    feature "renders member role", ctx do
      session =
        visit(ctx.session, "/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      for {member, role} <- ctx.members do
        assert_has(
          session,
          Query.css("[aria-label=\"Role for #{member.name}\"]",
            text: to_string(role.role)
          )
        )
      end
    end

    feature "updates member role", ctx do
      session =
        visit(ctx.session, "/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      for {member, role} <- ctx.members do
        if role.role != :owner do
          find(
            session,
            Query.css("[aria-label=\"Role for #{member.name}\"] button"),
            fn button ->
              Element.click(button)
              take_screenshot(session)
            end
          )
        end
      end
    end

    feature "renders member join date", ctx do
      session =
        visit(ctx.session, "/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      for {_, role} <- ctx.members do
        assert_has(
          session,
          Query.css("[aria-label='Team members']",
            text: dt_to_string(role.inserted_at)
          )
        )
      end
    end
  end
end
