defmodule Runa.TeamsTest do
  @moduledoc false

  use Runa.DataCase, async: true

  @moduletag :teams

  alias Runa.Teams
  alias Runa.Teams.Team

  setup do
    team = insert(:team)

    {:ok, team: team}
  end

  describe "teams context" do
    test "returns all entities", ctx do
      {:ok, {[team], %{}}} = Teams.index()

      assert team.id == ctx.team.id
    end

    test "returns entity with given id", ctx do
      assert Teams.get(ctx.team.id) == {:ok, ctx.team}
    end

    test "creates entity with valid data" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %Team{}} = Teams.create(valid_attrs)
    end

    test "returns error changeset during creation with invalid data" do
      invalid_attrs = %{}

      assert {:error, %Ecto.Changeset{}} = Teams.create(invalid_attrs)
    end

    test "updates entity with valid data", ctx do
      update_attrs = %{title: "some updated title"}

      assert {:ok, %Team{} = team} = Teams.update(ctx.team, update_attrs)

      assert team.title == "some updated title"
    end

    test "returns error changeset after update with invalid data", ctx do
      invalid_attrs = %{title: nil}

      assert {:error, %Ecto.Changeset{}} = Teams.update(ctx.team, invalid_attrs)

      assert {:ok, ctx.team} == Teams.get(ctx.team.id)
    end

    test "deletes entity", ctx do
      assert {:ok, %Team{}} = Teams.delete(ctx.team)

      assert {:error, %Ecto.NoResultsError{}} = Teams.get(ctx.team.id)
    end

    test "returns changeset", ctx do
      assert %Ecto.Changeset{} = Teams.change(ctx.team)
    end
  end
end
