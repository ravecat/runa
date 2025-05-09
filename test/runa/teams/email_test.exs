defmodule Runa.Teams.EmailTest do
  use ExUnit.Case, async: true
  import Swoosh.TestAssertions

  alias Runa.Teams.Email
  alias Runa.Teams.Invitation

  test "deliver_invitation_to_team/1" do
    invitation = %Invitation{
      token: "abc123",
      email: "bob@example.com",
      role: :owner
    }

    Email.deliver_invitation_to_team(invitation)

    assert_email_sent(
      subject: "Runa team invitation",
      to: {"", "bob@example.com"},
      text_body: ~r/You have been invited to join the team as a owner\./
    )
  end
end
