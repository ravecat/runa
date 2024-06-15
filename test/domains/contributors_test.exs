defmodule Runa.ContributorsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :contributors

  alias Runa.Contributors
  alias Runa.Contributors.Contributor
  alias Runa.Repo

  import Runa.Factory

  @roles Application.compile_env(:runa, :permissions)

  setup do
    team = insert(:team)
    user = insert(:user)
    role = insert(:role, title: @roles[:owner])
    contributor = insert(:contributor, role: role, team: team, user: user)

    {:ok, contributor: contributor}
  end

  describe "contributors" do
    test "returns all contributors", ctx do
      assert [contributor] = Contributors.get_contributors()

      assert contributor.id == ctx.contributor.id
      assert contributor.role_id == ctx.contributor.role_id
      assert contributor.team_id == ctx.contributor.team_id
      assert contributor.user_id == ctx.contributor.user_id
    end

    test "returns the record with given set", ctx do
      assert ctx.contributor ==
               Contributors.get_contributor!(ctx.contributor.id)
               |> Repo.preload([:team, :user, :role])
    end

    test "creates a contributor with valid data", ctx do
      user = insert(:user)
      team = insert(:team)

      assert {:ok, %Contributor{}} =
               Contributors.create_contributor(%{
                 team_id: team.id,
                 user_id: user.id,
                 role_id: ctx.contributor.role_id
               })
    end

    test "returns error changeset after creation with invalid data" do
      assert {:error, %Ecto.Changeset{}} = Contributors.create_contributor(%{})
    end

    test "updates the contributor with valid data ", ctx do
      user = insert(:user)
      team = insert(:team)

      update_attrs = %{
        team_id: team.id,
        user_id: user.id
      }

      assert {:ok, %Contributors.Contributor{} = contributor} =
               Contributors.update_contributor(
                 ctx.contributor,
                 update_attrs
               )

      assert contributor.team_id == team.id
    end

    test "returns error changeset with invalid data", ctx do
      invalid_attrs = %{
        team_id: nil
      }

      assert {:error, %Ecto.Changeset{}} =
               Contributors.update_contributor(ctx.contributor, invalid_attrs)

      assert contributor = Contributors.get_contributor!(ctx.contributor.id)

      assert contributor.id == ctx.contributor.id
      assert contributor.role_id == ctx.contributor.role_id
      assert contributor.team_id == ctx.contributor.team_id
      assert contributor.user_id == ctx.contributor.user_id
    end

    test "deletes the contributor", ctx do
      assert {:ok, %Contributors.Contributor{}} =
               Contributors.delete_contributor(ctx.contributor)

      assert_raise Ecto.NoResultsError, fn ->
        Contributors.get_contributor!(ctx.contributor.id)
      end
    end

    test "returns a contributor changeset", ctx do
      assert %Ecto.Changeset{} =
               Contributors.change_contributor(ctx.contributor)
    end
  end
end
