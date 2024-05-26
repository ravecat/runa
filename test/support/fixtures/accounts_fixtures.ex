defmodule Runa.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Accounts` context.
  """

  alias Runa.Accounts

  import Runa.{RolesFixtures}

  @doc """
  Generate a user.
  """
  def create_aux_user(attrs \\ %{}) do
    create_aux_role()

    {:ok, user} =
      attrs
      |> Enum.into(%{
        uid: "johndoe",
        name: "John Doe",
        avatar: "https://example.com/avatar.jpg",
        email: "john.doe@mail.com"
      })
      |> Accounts.create_or_find_user()

    user
  end
end
