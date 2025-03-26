defmodule Runa.TeamsTest do
  use Runa.DataCase, async: true

  @moduletag :teams

  alias Runa.Contributors.Contributor
  alias Runa.Teams
  alias Runa.Teams.Team

  setup do
    team = insert(:team)
    user = insert(:user)

    {:ok, team: team, scope: Scope.new(user), user: user}
  end

  describe "teams context" do
    test "returns all entities", ctx do
      {:ok, {data, %{}}} = Teams.index(ctx.scope)

      for item <- data do
        assert(is_struct(item, Team))
      end
    end

    test "returns entity with given id", ctx do
      assert {:ok, team} = Teams.get(ctx.scope, ctx.team.id)
      assert team.id == ctx.team.id
    end

    test "creates entity with valid data", ctx do
      attrs = %{title: "some title"}

      assert {:ok, %Team{}} = Teams.create(ctx.scope, attrs)
    end

    test "sends broadcast after create", ctx do
      attrs = %{title: "some title"}

      Teams.subscribe(ctx.scope)

      {:ok, data} = Teams.create(ctx.scope, attrs)

      assert_receive %Events.TeamCreated{data: ^data}
    end

    test "returns error changeset during creation with invalid data", ctx do
      attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Teams.create(ctx.scope, attrs)
    end

    test "updates entity with valid data", ctx do
      assert {:ok, %Team{title: "some updated title"}} =
               Teams.update(ctx.scope, ctx.team, %{title: "some updated title"})
    end

    test "sends broadcast after update", ctx do
      attrs = %{title: "some title"}

      Teams.subscribe(ctx.scope)

      {:ok, data} = Teams.update(ctx.scope, ctx.team, attrs)

      assert_receive %Events.TeamUpdated{data: ^data}
    end

    test "returns error changeset after update with invalid data", ctx do
      invalid_attrs = %{title: nil}

      assert {:error, %Ecto.Changeset{}} =
               Teams.update(ctx.scope, ctx.team, invalid_attrs)
    end

    test "deletes entity", ctx do
      assert {:ok, %Team{}} = Teams.delete(ctx.scope, ctx.team)

      assert {:error, %Ecto.NoResultsError{}} =
               Teams.get(ctx.scope, ctx.team.id)
    end

    test "sends broadcast after delete the entity", ctx do
      Teams.subscribe(ctx.scope)

      assert {:ok, %Team{} = data} = Teams.delete(ctx.scope, ctx.team)

      assert_receive %Events.TeamDeleted{data: ^data}
    end

    test "returns changeset", ctx do
      assert %Ecto.Changeset{} = Teams.change(ctx.team)
    end

    test "returns team owner", ctx do
      user = insert(:user)

      insert(:contributor, user: user, team: ctx.team, role: :owner)

      assert owner = Teams.get_owner(ctx.team)

      assert owner.id == user.id
    end

    test "returns nil when team has no owner", ctx do
      Repo.delete_all(
        from(c in Contributor,
          where: c.team_id == ^ctx.team.id and c.role == :owner
        )
      )

      assert nil == Teams.get_owner(ctx.team)
    end

    test "returns list of team members", ctx do
      user1 = insert(:user)
      user2 = insert(:user)

      insert(:contributor, user: user1, team: ctx.team)
      insert(:contributor, user: user2, team: ctx.team)

      members = Teams.get_members(ctx.team)

      assert length(members) == 2

      for member <- members do
        assert %Contributor{} = member
        assert Ecto.assoc_loaded?(member.user)
      end
    end
  end
end
