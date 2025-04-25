defmodule Runa.Mailer do
  use Swoosh.Mailer, otp_app: :runa

  alias Runa.Invitations.Invitation

  import Swoosh.Email

  @app_name Mix.Project.config()[:app]
  @domain "runa.io"

  def send_invitation_email(%Invitation{token: token, email: email, role: role}) do
    acceptance_url = "https://#{@domain}/invitations/accept/#{token}"

    email_content = """
    Hello,

    You have been invited to join the team as a #{role}.

    Please accept your invitation by clicking the link below:
    #{acceptance_url}

    Best regards,
    The #{String.capitalize(@app_name)} Team
    """

    new_email =
      Swoosh.Email.new()
      |> to(email)
      |> from("no-reply@#{@domain}")
      |> subject("#{String.capitalize(@app_name)} team invitation")
      |> text_body(email_content)

    deliver(new_email)
  end
end
