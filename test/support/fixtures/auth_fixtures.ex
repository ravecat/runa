defmodule Runa.AuthFixtures do
  @moduledoc """
  Module for handling authentication fixtures.
  """

  import Runa.RolesFixtures

  def create_aux_success_auth() do
    create_aux_role()

    %Ueberauth.Auth{
      uid: "auth0|1234567890",
      provider: :auth0,
      info: %Ueberauth.Auth.Info{
        name: "John Doe",
        email: "john@mail.com",
        first_name: "John",
        last_name: "Doe",
        urls: %{avatar_url: "https://example.com/image.jpg"},
        nickname: "johndoe",
        image: "https://example.com/image.jpg"
      }
    }
  end
end
