defmodule Runa.Teams.Test do
  @moduledoc false

  use Runa.DataCase

  alias Runa.Teams
  alias Runa.Teams.Team

  import Runa.Teams.Fixtures

  @invalid_attrs %{title: nil, owner_id: nil}
  @valid_attrs %{title: "some title", owner_id: "some owner_id"}

  describe "teams" do
    setup [:create_aux_team]

    test "get_teams/0 returns all teams", %{team: team} do
      assert Teams.get_teams() == [team]
    end

    test "get_team!/1 returns the team with given id", %{team: team} do
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Teams.create_team(@valid_attrs)
      assert team.title == "some title"
      assert team.owner_id == "some owner_id"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team", %{team: team} do
      update_attrs = %{title: "some updated title", owner_id: "some updated owner_id"}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)
      assert team.title == "some updated title"
      assert team.owner_id == "some updated owner_id"
    end

    test "update_team/2 with invalid data returns error changeset", %{team: team} do
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team", %{team: team} do
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset", %{team: team} do
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end

    test "get_teams_by/1 returns teams by owner_id", %{team: team} do
      assert [team] == Teams.get_teams_by(owner_id: team.owner_id)

      Teams.create_team(@valid_attrs)

      assert length(Teams.get_teams_by(owner_id: team.owner_id)) == 2
    end

    test "get_teams_by/1 returns empty list if no teams found" do
      assert [] == Teams.get_teams_by(owner_id: "nonexistent")
    end

    test "ensure_team/2 returns the team if it exists", %{team: team} do
      assert {:ok, [team]} == Teams.ensure_team([owner_id: team.owner_id], @valid_attrs)
    end

    test "ensure_team/2 creates a team if it does not exist" do
      assert [%Team{} = team] = Teams.get_teams()

      assert {:ok, [%Team{} = nonexistent]} =
               Teams.ensure_team([owner_id: "nonexistent"], %{
                 title: "new title",
                 owner_id: "nonexistent"
               })

      assert [%Team{} = team, %Team{} = nonexistent] == Teams.get_teams()
    end

    test "ensure_team/2 returns error changeset if team creation fails" do
      assert {:error, %Ecto.Changeset{}} = Teams.ensure_team([owner_id: "nonexistent"], %{})
    end
  end
end
