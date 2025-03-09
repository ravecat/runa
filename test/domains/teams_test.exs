defmodule Runa.TeamsTest do
  @moduledoc false

  use Runa.DataCase, async: true

  @moduletag :teams

  alias Runa.Accounts.User
  alias Runa.Contributors
  alias Runa.Contributors.Contributor
  alias Runa.Teams
  alias Runa.Teams.Team

  setup do
    team = insert(:team)

    {:ok, team: team}
  end

  describe "teams context" do
    test "returns all entities" do
      {:ok, {data, %{}}} = Teams.index()

      Enum.each(data, &assert(is_struct(&1, Team)))
    end

    test "returns entity with given id", ctx do
      assert {:ok, team} = Teams.get(ctx.team.id)
      assert team.id == ctx.team.id
    end

    test "creates entity with valid data" do
      attrs = %{title: "some title"}

      assert {:ok, %Team{}} = Teams.create(attrs)
    end

    test "sends broadcast after create" do
      attrs = %{title: "some title"}

      Teams.subscribe()

      {:ok, data} = Teams.create(attrs)

      assert_receive {:team_created, ^data}
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Teams.create(invalid_attrs)
    end

    test "creates entity with linked user" do
      user = insert(:user)

      assert {:ok, %Team{} = team} = Teams.create(%{title: "some title"}, user)

      assert %Contributor{} =
               Contributors.get_by(user_id: user.id, team_id: team.id)
    end

    test "returns error changeset during creation with invalid linked user" do
      assert {:error, %Ecto.Changeset{}} =
               Teams.create(%{title: "some title"}, %User{id: 1})
    end

    test "updates entity with valid data", ctx do
      attrs = %{title: "some updated title"}

      assert {:ok, %Team{} = data} = Teams.update(ctx.team, attrs)

      assert data.title == "some updated title"
    end

    test "sends broadcast after update", ctx do
      attrs = %{title: "some title"}

      Teams.subscribe()

      {:ok, data} = Teams.update(ctx.team, attrs)

      assert_receive {:team_updated, ^data}
    end

    test "returns error changeset after update with invalid data", ctx do
      invalid_attrs = %{title: nil}

      assert {:error, %Ecto.Changeset{}} = Teams.update(ctx.team, invalid_attrs)
    end

    test "deletes entity", ctx do
      assert {:ok, %Team{}} = Teams.delete(ctx.team)

      assert {:error, %Ecto.NoResultsError{}} = Teams.get(ctx.team.id)
    end

    test "sends broadcast after delete the entity", ctx do
      Teams.subscribe()

      assert {:ok, %Team{} = data} = Teams.delete(ctx.team)

      assert_receive {:team_deleted, ^data}
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
