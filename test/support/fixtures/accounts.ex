defmodule Runa.Accounts.Fixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "John Doe",
        avatar: "https://example.com/avatar.jpg",
      })
      |> Runa.Accounts.create_user()

    user
  end
end
