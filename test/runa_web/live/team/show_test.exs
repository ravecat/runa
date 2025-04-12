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

    {:ok,
     members: members, scope: scope, owner: owner, contributors: contributors}
  end

  describe "team dashboard" do
    feature "renders member name", ctx do
      session =
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
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
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
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

    feature "renders member join date", ctx do
      session =
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
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

  describe "team owner" do
    feature "has ability to delete non-owner members", ctx do
      session =
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      {member, _} =
        Enum.find(ctx.members, fn {_, role} -> role.role != :owner end)

      assert_has(
        session,
        Query.css("[aria-label=\"Member #{member.name} form\"]",
          text: member.name
        )
      )
      |> click(Query.css("[aria-label=\"Delete #{member.name} from team\"]"))
      |> click(Query.css("[aria-label=\"Confirm delete contributor\"]"))
      |> visit("/team")
      |> assert_has(
        Query.css("[aria-label=\"Member #{member.name} form\"]", count: 0)
      )
    end

    feature "has ability to change member role", ctx do
      session =
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
        |> assert_has(Query.css("[aria-label='Team members']"))

      for {member, role} <- ctx.members do
        if role.role != :owner do
          click(
            session,
            Query.css("[aria-label=\"Role for #{member.name}\"] button")
          )
          |> click(Query.css("[data-select-item]", text: "admin"))
          |> visit("/team")
          |> assert_has(
            Query.css("[aria-label=\"Role for #{member.name}\"]", text: "admin")
          )
        end
      end
    end
  end
end
