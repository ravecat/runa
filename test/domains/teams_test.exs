defmodule Runa.TeamsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :teams

  alias Runa.Teams
  alias Runa.Teams.Team

  import Runa.Teams.Fixtures

  @invalid_attrs %{title: nil}
  @valid_attrs %{title: "some title"}

  describe "teams" do
    setup [:create_aux_team]

    test "get_teams/0 returns all teams", %{team: team} do
      assert Teams.get_teams() == [team]
    end

    test "get_team!/1 returns the team with given id", %{
      team: team
    } do
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Teams.create_team(@valid_attrs)

      assert team.title == "some title"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team",
         %{team: team} do
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)

      assert team.title == "some updated title"
    end

    test "update_team/2 with invalid data returns error changeset",
         %{team: team} do
      assert {:error, %Ecto.Changeset{}} =
               Teams.update_team(team, @invalid_attrs)

      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team", %{team: team} do
      assert {:ok, %Team{}} = Teams.delete_team(team)

      assert_raise Ecto.NoResultsError, fn ->
        Teams.get_team!(team.id)
      end
    end

    test "change_team/1 returns a team changeset", %{
      team: team
    } do
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end
end
