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
        uid: "123",
        name: "John Doe",
        avatar: "https://example.com/avatar.jpg",
      })
      |> Runa.Accounts.create_user()

    %{user: user}
  end
end
