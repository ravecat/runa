defmodule Runa.Repo.Helpers.Test do
  @moduledoc false

  use Runa.DataCase

  alias Runa.Teams.Team
  alias Runa.Repo.Helpers

  import Runa.Teams.Fixtures

  setup [:create_aux_team]

  test "ensure/3 creates a new entry when none exists", %{team: team} do
    assert {:ok, [^team]} = Helpers.ensure(Team, owner_id: team.owner_id)
  end

  test "ensure/3 returns existing entries" do
    assert {:ok, [team]} =
             Helpers.ensure(Team, [owner_id: "nonexisting"], %{
               owner_id: "nonexisting",
               title: "Team 2"
             })

    assert team.title == "Team 2"
  end

  test "ensure/3 return changeset error" do
    assert {:error, %Ecto.Changeset{} = changeset} =
             Helpers.ensure(Team, [owner_id: "nonexisting"], %{
               owner_id: nil,
               title: "Team 2"
             })

    assert changeset.valid? == false
  end
end
