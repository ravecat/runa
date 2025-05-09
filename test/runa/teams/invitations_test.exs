defmodule Runa.Teams.InvitationsTest do
  use Runa.DataCase, async: true

  alias Runa.Events
  alias Runa.Teams.Invitation
  alias Runa.Teams.Invitations

  @moduletag :invitations

  setup do
    team = insert(:team)
    user = insert(:user)

    {:ok, team: team, user: user}
  end

  describe "create_invitation/1" do
    test "creates an invitation with valid data", %{team: team, user: user} do
      attrs = %{
        email: user.email,
        role: "admin",
        team_id: team.id,
        invited_by_user_id: user.id
      }

      assert {:ok, %Invitation{}} = Invitations.create_invitation(attrs)
    end

    test "sends broadcast after create", %{team: team, user: user} do
      Invitations.subscribe()

      attrs = %{
        email: user.email,
        role: "admin",
        team_id: team.id,
        invited_by_user_id: user.id
      }

      {:ok, data} = Invitations.create_invitation(attrs)

      assert_receive %Events.InvitationCreated{data: ^data}
    end

    test "returns error changeset on invalid data" do
      assert {:error, %Ecto.Changeset{}} = Invitations.create_invitation(%{})
    end
  end
end
