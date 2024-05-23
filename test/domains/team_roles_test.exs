defmodule Runa.ContributorsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :contributors

  alias Runa.Contributors

  import Runa.{
    AccountsFixtures,
    TeamsFixtures,
    RolesFixtures,
    ContributorsFixtures
  }

  describe "contributors" do
    setup [
      :create_aux_role,
      :create_aux_user,
      :create_aux_team
    ]

    test "returns all contributors", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      contributors = Contributors.get_contributors()

      assert Enum.member?(contributors, contributor)
    end

    test "returns the record with given set", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert Contributors.get_contributor!(%{
               team_id: ctx.team.id,
               user_id: ctx.user.id,
               role_id: ctx.role.id
             }) == contributor
    end

    test "creates a contributor with valid data", ctx do
      assert {:ok, %Contributors.Contributor{}} =
               Contributors.create_contributor(%{
                 team_id: ctx.team.id,
                 user_id: ctx.user.id,
                 role_id: ctx.role.id
               })
    end

    test "returns error changeset after creation with invalid data " do
      assert {:error, %Ecto.Changeset{}} = Contributors.create_contributor(%{})
    end

    test "update_contributor/2 with valid data updates the contributor", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      %{team: new_team} = create_aux_team(%{name: "new_team"})

      update_attrs = %{
        team_id: new_team.id
      }

      assert {:ok, %Contributors.Contributor{} = contributor} =
               Contributors.update_contributor(
                 contributor,
                 update_attrs
               )

      assert contributor.team_id == new_team.id
    end

    test "update_contributor/2 with invalid data returns error changeset", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert {:error, %Ecto.Changeset{}} =
               Contributors.update_contributor(contributor, %{
                 team_id: nil
               })

      assert contributor ==
               Contributors.get_contributor!(%{
                 team_id: ctx.team.id,
                 user_id: ctx.user.id,
                 role_id: ctx.role.id
               })
    end

    test "delete_contributor/1 deletes the contributor", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert {:ok, %Contributors.Contributor{}} =
               Contributors.delete_contributor(contributor)

      assert_raise Ecto.NoResultsError, fn ->
        Contributors.get_contributor!(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })
      end
    end

    test "change_contributor/1 returns a contributor changeset", ctx do
      contributor =
        create_aux_contributor(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert %Ecto.Changeset{} = Contributors.change_contributor(contributor)
    end
  end
end
