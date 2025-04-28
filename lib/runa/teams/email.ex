defmodule Runa.Teams.Email do
  use RunaWeb, :email

  def invite_to_team(%Runa.Teams.Invitation{
        token: token,
        email: email,
        role: role
      }) do
    acceptance_url = "#{@app_base_url}/invitations/accept/#{token}"
    app_name = String.capitalize(@app_name)

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
    |> from(@no_reply_email)
    |> subject("#{app_name} team invitation")
    |> text_body(email_content)
  end
end
