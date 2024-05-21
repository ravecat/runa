defmodule Runa.AuthFixtures do
  @moduledoc """
  Module for handling authentication fixtures.
  """

  @auth %Ueberauth.Auth{
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

  def create_aux_success_auth(attrs \\ %{})

  def create_aux_success_auth(%{test: _}) do
    %{auth: @auth}
  end

  def create_aux_success_auth(attrs) do
    attrs |> Enum.into(@auth)
  end
end
