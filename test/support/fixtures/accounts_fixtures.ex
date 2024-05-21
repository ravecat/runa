defmodule Runa.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Runa.Accounts` context.
  """

  alias Runa.Accounts

  @default_attrs %{
    uid: "johndoe",
    name: "John Doe",
    avatar: "https://example.com/avatar.jpg",
    email: "john.doe@mail.com"
  }

  @doc """
  Generate a user.
  """
  def create_aux_user(attrs \\ %{})

  def create_aux_user(%{test: _} = attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(@default_attrs)
      |> Accounts.create_or_find_user()

    %{user: user}
  end

  def create_aux_user(attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(@default_attrs)
      |> Accounts.create_or_find_user()

    user
  end
end
