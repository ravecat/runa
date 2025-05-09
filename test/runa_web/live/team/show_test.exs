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
     team: team,
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
          Query.css("[aria-label='Member #{member.name} form']",
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
          Query.css("[aria-label='Role for #{member.name}']",
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
        Query.css("[aria-label='Member #{member.name} form']",
          text: member.name
        )
      )
      |> click(Query.css("[aria-label='Delete #{member.name} from team']"))
      |> click(Query.css("[aria-label='Confirm delete contributor']"))
      |> assert_has(
        Query.css("[aria-label='Member #{member.name} form']", count: 0)
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
            Query.css("[aria-label='Role for #{member.name}'] button")
          )
          |> click(Query.css("[data-select-item]", text: "admin"))
          |> assert_has(
            Query.css("[aria-label='Role for #{member.name}']", text: "admin")
          )
        end
      end
    end

    feature "has ability to invite new members", ctx do
      session =
        put_session(ctx.session, :user_id, ctx.user.id)
        |> visit("/team")
        |> assert_has(Query.css("[aria-label='Team members']"))
        |> click(Query.css("[aria-label='Add team members']"))
        |> assert_has(
          Query.css("[aria-label='Email input for inviting member']")
        )
        |> fill_in(Query.css("[aria-label='Email input for inviting member']"),
          with: "test@example.com"
        )
        |> click(Query.css("[aria-label='Confirm invite']"))
        |> assert_has(Query.css("[aria-label='Confirm invite']"))
    end

    feature "hasn't ability to leave team", ctx do
      put_session(ctx.session, :user_id, ctx.user.id)
      |> visit("/team")
      |> assert_has(Query.css("[aria-label='Team members']"))
      |> assert_has(Query.css("[aria-label='Leave team']", count: 0))
    end
  end

  describe "team non-owner" do
    feature "hasn't ability to delete team member", ctx do
      user = insert(:user)

      insert(:contributor, team: ctx.team, user: user, role: :editor)

      session = ctx.session |> put_session(:user_id, user.id) |> visit("/team")

      for {member, _role} <- ctx.members do
        assert_has(
          session,
          Query.css("[aria-label='Delete #{member.name} from team']", count: 0)
        )
      end
    end

    feature "has ability to leave team", ctx do
      user = insert(:user)
      insert(:contributor, team: ctx.team, user: user, role: :editor)

      session =
        put_session(ctx.session, :user_id, user.id)
        |> visit("/team")
        |> assert_has(Query.text(ctx.team.title))
        |> take_screenshot()
        |> assert_has(Query.css("[aria-label='Leave team']"))
        |> click(Query.css("[aria-label='Leave team']"))
        |> assert_has(Query.css("[aria-label='Confirm leaving team']"))
        |> click(Query.css("[aria-label='Confirm leaving team']"))
        |> assert_has(Query.text(ctx.team.title, count: 0))

      assert current_path(session) == "/profile"
    end
  end
end
