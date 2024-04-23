defmodule Runa.Repo.Helpers.Test do
  @moduledoc false
  use Runa.DataCase

  @moduletag :repo

  alias Runa.Teams.Team
  alias Runa.Repo.Helpers

  import Runa.Teams.Fixtures

  setup [:create_aux_team]

  test "ensure/3 returns existing entries", %{team: team} do
    assert {:ok, [^team]} = Helpers.ensure(Team, title: team.title)
  end

  test "ensure/3 creates a new entry when none exists" do
    assert {:ok, [team]} =
             Helpers.ensure(Team, [title: "nonexisting"], %{
               title: "Team 2"
             })

    assert team.title == "Team 2"
  end

  test "ensure/3 return changeset error" do
    assert {:error, %Ecto.Changeset{} = changeset} =
             Helpers.ensure(Team, [title: "nonexisting"], %{
               title: nil
             })

    assert changeset.valid? == false
  end
end
