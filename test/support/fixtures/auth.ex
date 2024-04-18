defmodule Runa.Auth.Fixtures do
  def create_aux_success_auth(_) do
    auth = %Ueberauth.Auth{
      uid: "auth0|1234567890",
      provider: :auth0,
      info: %{
        name: "John Doe",
        email: "john@mail.com",
        first_name: "John",
        last_name: "Doe",
        urls: %{avatar_url: "https://example.com/image.jpg"},
        nickname: "johndoe",
        image: "https://example.com/image.jpg"
      }
    }

    %{auth: auth}
  end
end
