defmodule Runa.TeamsTest do
  @moduledoc false

  use Runa.DataCase

  @moduletag :teams

  alias Runa.{Teams.Team, Teams}

  import Runa.TeamsFixtures

  @invalid_attrs %{title: nil}
  @valid_attrs %{title: "some title"}

  describe "teams" do
    setup [:create_aux_team]

    test "returns all teams", %{team: team} do
      assert Teams.get_teams() == [team]
    end

    test "returns the team with given id", %{
      team: team
    } do
      assert Teams.get_team!(team.id) == team
    end

    test "creates a team with valid data" do
      assert {:ok, %Team{}} = Teams.create_team(@valid_attrs)
    end

    test "returns error changeset after create with invalid data" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "updates the team with valid data",
         %{team: team} do
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)

      assert team.title == "some updated title"
    end

    test "returns error changeset after update with invalid data",
         %{team: team} do
      assert {:error, %Ecto.Changeset{}} =
               Teams.update_team(team, @invalid_attrs)

      assert team == Teams.get_team!(team.id)
    end

    test "deletes the team", %{team: team} do
      assert {:ok, %Team{}} = Teams.delete_team(team)

      assert_raise Ecto.NoResultsError, fn ->
        Teams.get_team!(team.id)
      end
    end

    test "returns a team changeset", %{
      team: team
    } do
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end
end
