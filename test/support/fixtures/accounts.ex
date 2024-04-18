defmodule Runa.Accounts.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def create_aux_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        uid: "uid",
        name: "John Doe",
        avatar: "https://example.com/avatar.jpg",
        email: "john.doe@mail.com"
      })
      |> Runa.Accounts.create_user()

    %{user: user}
  end
end
