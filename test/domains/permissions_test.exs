defmodule Runa.PermissionsTest do
  use Runa.DataCase

  @moduletag :permissions

  alias Runa.Permissions
  alias Runa.Permissions.TeamRole

  import Runa.Accounts.Fixtures
  import Runa.Teams.Fixtures
  import Runa.Permissions.Fixtures

  describe "team_roles" do
    setup [
      :create_aux_user,
      :create_aux_team,
      :create_aux_role
    ]

    test "get_team_roles/0 returns all team_roles", %{
      team: team,
      user: user,
      role: role
    } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      assert Permissions.get_team_roles() == [team_role]
    end

    test "get_team_role!/1 returns the team_role with given id",
         %{
           team: team,
           user: user,
           role: role
         } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      assert Permissions.get_team_role!(%{
               team_id: team.id,
               user_id: user.id,
               role_id: role.id
             }) == team_role
    end

    test "create_team_role/1 with valid data creates a team_role",
         %{
           team: team,
           user: user,
           role: role
         } do
      assert {:ok, %TeamRole{}} =
               Permissions.create_team_role(%{
                 team_id: team.id,
                 user_id: user.id,
                 role_id: role.id
               })
    end

    test "create_team_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Permissions.create_team_role(%{})
    end

    test "update_team_role/2 with valid data updates the team_role",
         %{
           team: team,
           user: user,
           role: role
         } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      %{team: new_team} = create_aux_team(%{name: "new_team"})

      update_attrs = %{
        team_id: new_team.id
      }

      assert {:ok, %TeamRole{} = team_role} =
               Permissions.update_team_role(
                 team_role,
                 update_attrs
               )

      assert team_role.team_id == new_team.id
    end

    test "update_team_role/2 with invalid data returns error changeset",
         %{
           team: team,
           user: user,
           role: role
         } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      assert {:error, %Ecto.Changeset{}} =
               Permissions.update_team_role(team_role, %{
                 team_id: nil
               })

      assert team_role ==
               Permissions.get_team_role!(%{
                 team_id: team.id,
                 user_id: user.id,
                 role_id: role.id
               })
    end

    test "delete_team_role/1 deletes the team_role", %{
      team: team,
      user: user,
      role: role
    } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      assert {:ok, %TeamRole{}} = Permissions.delete_team_role(team_role)

      assert_raise Ecto.NoResultsError, fn ->
        Permissions.get_team_role!(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })
      end
    end

    test "change_team_role/1 returns a team_role changeset",
         %{
           team: team,
           user: user,
           role: role
         } do
      %{team_role: team_role} =
        create_aux_team_role(%{
          team_id: team.id,
          user_id: user.id,
          role_id: role.id
        })

      assert %Ecto.Changeset{} = Permissions.change_team_role(team_role)
    end
  end
end
