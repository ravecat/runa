defmodule RunaWeb.Live.Team.ShowTest do
  use RunaWeb.FeatureCase

  import RunaWeb.Adapters.DateTime

  @moduletag :teams

  setup do
    user = insert(:user)
    team = insert(:team)
    scope = Scope.new(user)
    owner = insert(:contributor, team: team, user: user, role: :owner)

    contributors =
      insert_list(3, :contributor,
        team: team,
        user: fn -> insert(:user) end,
        role: :editor
      )

    members = Enum.map(contributors, &{&1.user, &1}) ++ [{owner.user, owner}]

    {:ok,
     members: members,
     scope: scope,
     owner: owner,
     contributors: contributors,
     user: user}
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
          |> assert_has(
            Query.css("[aria-label=\"Role for #{member.name}\"]", text: "admin")
          )
        end
      end
    end
  end
end
