defmodule Runa.ContributorsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :contributors

  alias Runa.Contributors
  alias Runa.Contributors.Contributor

  setup do
    team = insert(:team)
    user = insert(:user)

    contributor =
      insert(:contributor, team: team, user: user)

    {:ok, contributor: contributor, team: team, user: user}
  end

  describe "contributors context" do
    test "returns all entities" do
      data = Contributors.index()

      Enum.each(data, &assert(is_struct(&1, Contributor)))
    end

    test "returns an entity with given id", ctx do
      assert {:ok, contributor} = Contributors.get(ctx.contributor.id)
      assert contributor.id == ctx.contributor.id
    end

    test "returns error if entity does not exist" do
      assert {:error, %Ecto.NoResultsError{}} = Contributors.get(123)
    end

    test "creates an entity with valid data", ctx do
      attrs = %{
        team_id: ctx.team.id,
        user_id: ctx.user.id,
        role: :owner
      }

      assert {:ok, %Contributor{}} = Contributors.create(attrs)
    end

    test "returns error changeset after creation with invalid data" do
      assert {:error, %Ecto.Changeset{}} = Contributors.create(%{})
    end

    test "updates the entity with valid data ", ctx do
      insert(:contributor, team: ctx.team, user: ctx.user, role: :viewer)

      attrs = %{
        team_id: ctx.team.id,
        user_id: ctx.user.id,
        role: :owner
      }

      assert {:ok, %Contributors.Contributor{} = contributor} =
               Contributors.update(
                 ctx.contributor,
                 attrs
               )

      assert contributor.role == :owner
    end

    test "returns error changeset on update with invalid data", ctx do
      attrs = %{
        team_id: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Contributors.update(ctx.contributor, attrs)
    end

    test "deletes the entity", ctx do
      assert {:ok, %Contributors.Contributor{}} =
               Contributors.delete(ctx.contributor)

      assert {:error, %Ecto.NoResultsError{}} =
               Contributors.get(ctx.contributor.id)
    end

    test "returns an entity changeset", ctx do
      assert %Ecto.Changeset{} =
               Contributors.change(ctx.contributor)
    end
  end
end
