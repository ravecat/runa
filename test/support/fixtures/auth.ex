defmodule Runa.Auth.Fixtures do
  def create_aux_success_auth(_) do
    auth = %Ueberauth.Auth{
      uid: "123",
      provider: :auth0,
      info: %{
        name: "John Doe",
        email: "john@mail.com",
        urls: %{avatar_url: "https://example.com/image.jpg"},
        nickname: "johndoe"
      }
    }

    %{auth: auth}
  end

  def create_aux_failure_auth(_) do
    auth = %Ueberauth.Auth{
      uid: nil,
      provider: :auth0,
      info: %{
        name: nil,
        email: nil,
        urls: %{avatar_url: nil},
        nickname: nil
      }
    }

    %{auth: auth}
  end
end
