defmodule Runa.TeamsTest do
  @moduledoc false

  use Runa.DataCase, async: true

  @moduletag :teams

  alias Runa.{Teams.Team, Teams}

  import Runa.TeamsFixtures

  setup do
    team = create_aux_team()

    %{team: team}
  end

  describe "teams" do
    test "returns all teams", ctx do
      assert Teams.get_teams() == [ctx.team]
    end

    test "returns the team with given id", ctx do
      assert Teams.get_team!(ctx.team.id) == ctx.team
    end

    test "creates a team with valid data" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Team{}} = Teams.create_team(valid_attrs)
    end

    test "returns error changeset after create with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Teams.create_team(invalid_attrs)
    end

    test "updates the team with valid data", ctx do
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Team{} = team} = Teams.update_team(ctx.team, update_attrs)

      assert team.title == "some updated title"
    end

    test "returns error changeset after update with invalid data", ctx do
      invalid_attrs = %{title: nil}

      assert {:error, %Ecto.Changeset{}} =
               Teams.update_team(ctx.team, invalid_attrs)

      assert ctx.team == Teams.get_team!(ctx.team.id)
    end

    test "deletes the team", ctx do
      assert {:ok, %Team{}} = Teams.delete_team(ctx.team)

      assert_raise Ecto.NoResultsError, fn ->
        Teams.get_team!(ctx.team.id)
      end
    end

    test "returns a team changeset", ctx do
      assert %Ecto.Changeset{} = Teams.change_team(ctx.team)
    end
  end
end
