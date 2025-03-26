defmodule Runa.ContributorsTest do
  @moduledoc false

  use Runa.DataCase, async: true

  @moduletag :contributors

  alias Runa.Contributors
  alias Runa.Contributors.Contributor

  setup do
    team = insert(:team)
    user = insert(:user)

    contributor = insert(:contributor, team: team, user: user)

    {:ok,
     contributor: contributor, team: team, user: user, scope: Scope.new(user)}
  end

  describe "contributors context" do
    test "returns all entities" do
      data = Contributors.index()

      Enum.each(data, &assert(is_struct(&1, Contributor)))
    end

    test "returns an entity with given id", ctx do
      assert {:ok, contributor} =
               Contributors.get(ctx.scope, ctx.contributor.id)

      assert contributor.id == ctx.contributor.id
    end

    test "returns error if entity does not exist", ctx do
      assert {:error, %Ecto.NoResultsError{}} = Contributors.get(ctx.scope, 123)
    end

    test "creates an entity with valid data", ctx do
      attrs = %{team_id: ctx.team.id, user_id: ctx.user.id, role: :owner}

      assert {:ok, %Contributor{}} = Contributors.create(ctx.scope, attrs)
    end

    test "sends broadcast after create", ctx do
      attrs = %{team_id: ctx.team.id, user_id: ctx.user.id, role: :owner}

      Contributors.subscribe(ctx.scope)

      {:ok, data} = Contributors.create(ctx.scope, attrs)

      assert_receive %Events.ContributorCreated{data: ^data}
    end

    test "returns error changeset after creation with invalid data", ctx do
      assert {:error, %Ecto.Changeset{}} = Contributors.create(ctx.scope, %{})
    end

    test "updates the entity with valid data ", ctx do
      insert(:contributor, team: ctx.team, user: ctx.user, role: :viewer)

      attrs = %{team_id: ctx.team.id, user_id: ctx.user.id, role: :owner}

      assert {:ok, %Contributor{} = contributor} =
               Contributors.update(ctx.scope, ctx.contributor, attrs)

      assert contributor.role == :owner
    end

    test "updates the entity with valid data and entity id", ctx do
      insert(:contributor, team: ctx.team, user: ctx.user, role: :viewer)

      attrs = %{team_id: ctx.team.id, user_id: ctx.user.id, role: :owner}

      assert {:ok, %Contributor{} = contributor} =
               Contributors.update(ctx.scope, ctx.contributor.id, attrs)

      assert contributor.role == :owner
    end

    test "sends broadcast after update", ctx do
      insert(:contributor, team: ctx.team, user: ctx.user, role: :viewer)

      attrs = %{team_id: ctx.team.id, user_id: ctx.user.id, role: :owner}

      Contributors.subscribe(ctx.scope)

      assert {:ok, %Contributor{} = data} =
               Contributors.update(ctx.scope, ctx.contributor.id, attrs)

      assert_receive %Events.ContributorUpdated{data: ^data}
    end

    test "returns error changeset on update with invalid data", ctx do
      attrs = %{role: nil}

      assert {:error, %Ecto.Changeset{}} =
               Contributors.update(ctx.scope, ctx.contributor, attrs)
    end

    test "deletes the entity", ctx do
      assert {:ok, %Contributor{}} =
               Contributors.delete(ctx.scope, ctx.contributor)

      assert {:error, %Ecto.NoResultsError{}} =
               Contributors.get(ctx.scope, ctx.contributor.id)
    end

    test "sends broadcast after delete the entity", ctx do
      Contributors.subscribe(ctx.scope)

      assert {:ok, %Contributor{} = data} =
               Contributors.delete(ctx.scope, ctx.contributor)

      assert_receive %Events.ContributorDeleted{data: ^data}
    end

    test "returns an entity changeset", ctx do
      assert %Ecto.Changeset{} = Contributors.change(ctx.contributor)
    end
  end
end
