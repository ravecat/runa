defmodule Runa.Teams.Email do
  @moduledoc """
  Emails related to team context.
  """
  use RunaWeb, :email

  @doc """
  Delivers an invitation email to a user.
  """
  def deliver_invitation_to_team(%Runa.Teams.Invitation{
        token: token,
        email: email,
        role: role
      }) do
    app_base_url = Application.get_env(:runa, :app_base_url)

    no_reply_email =
      "no-reply@#{Application.get_env(:runa, RunaWeb.Endpoint)[:url][:host]}"

    app_name = String.capitalize(@app_name)

    acceptance_url = "#{app_base_url}/invitations/accept/#{token}"

    email_content = """
    Hello,

    You have been invited to join the team as a #{role}.

    Please accept your invitation by clicking the link below:
    #{acceptance_url}

    Best regards,
    The #{app_name} Team
    """

    new()
    |> to(email)
    |> from(no_reply_email)
    |> subject("#{app_name} team invitation")
    |> text_body(email_content)
    |> deliver()
  end
end
