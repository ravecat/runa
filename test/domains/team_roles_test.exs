defmodule Runa.TeamRolesTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :team_roles

  alias Runa.TeamRoles

  import Runa.{
    AccountsFixtures,
    TeamsFixtures,
    RolesFixtures,
    TeamRolesFixtures
  }

  describe "team_roles" do
    setup [
      :create_aux_role,
      :create_aux_user,
      :create_aux_team
    ]

    test "returns all team_roles", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      team_roles = TeamRoles.get_team_roles()

      assert Enum.member?(team_roles, team_role)
    end

    test "returns the record with given set", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert TeamRoles.get_team_role!(%{
               team_id: ctx.team.id,
               user_id: ctx.user.id,
               role_id: ctx.role.id
             }) == team_role
    end

    test "creates a team_role with valid data", ctx do
      assert {:ok, %TeamRoles.TeamRole{}} =
               TeamRoles.create_team_role(%{
                 team_id: ctx.team.id,
                 user_id: ctx.user.id,
                 role_id: ctx.role.id
               })
    end

    test "returns error changeset after creation with invalid data " do
      assert {:error, %Ecto.Changeset{}} = TeamRoles.create_team_role(%{})
    end

    test "update_team_role/2 with valid data updates the team_role", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      %{team: new_team} = create_aux_team(%{name: "new_team"})

      update_attrs = %{
        team_id: new_team.id
      }

      assert {:ok, %TeamRoles.TeamRole{} = team_role} =
               TeamRoles.update_team_role(
                 team_role,
                 update_attrs
               )

      assert team_role.team_id == new_team.id
    end

    test "update_team_role/2 with invalid data returns error changeset", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert {:error, %Ecto.Changeset{}} =
               TeamRoles.update_team_role(team_role, %{
                 team_id: nil
               })

      assert team_role ==
               TeamRoles.get_team_role!(%{
                 team_id: ctx.team.id,
                 user_id: ctx.user.id,
                 role_id: ctx.role.id
               })
    end

    test "delete_team_role/1 deletes the team_role", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert {:ok, %TeamRoles.TeamRole{}} =
               TeamRoles.delete_team_role(team_role)

      assert_raise Ecto.NoResultsError, fn ->
        TeamRoles.get_team_role!(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })
      end
    end

    test "change_team_role/1 returns a team_role changeset", ctx do
      team_role =
        create_aux_team_role(%{
          team_id: ctx.team.id,
          user_id: ctx.user.id,
          role_id: ctx.role.id
        })

      assert %Ecto.Changeset{} = TeamRoles.change_team_role(team_role)
    end
  end
end
