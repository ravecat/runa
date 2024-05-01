defmodule Runa.Auth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  alias Runa.Accounts

  def find_or_create(%Auth{provider: :auth0} = auth) do
    with uid when not is_nil(uid) <- auth.uid,
         email when not is_nil(email) <- get_email(auth),
         user when is_nil(user) <-
           Runa.Repo.get_by(Accounts.User, email: email),
         {:ok, new_user} <-
           Accounts.create_user(%{
             uid: auth.uid,
             name: get_name(auth),
             avatar: get_avatar(auth),
             nickname: get_nickname(auth),
             email: get_email(auth)
           }) do
      {:ok, new_user}
    else
      %Accounts.User{} = user ->
        {:ok, user}

      {:error, %Ecto.Changeset{}} ->
        {:error, "Failed to create user"}

      _ ->
        {:error, "Required authentication information is missing."}
    end
  end

  defp get_avatar(%Auth{info: %{urls: %{avatar_url: image}}})
       when image not in [nil, ""] do
    image
  end

  defp get_avatar(%Auth{info: %{image: image}})
       when image not in [nil, ""] do
    image
  end

  defp get_avatar(auth) do
    Logger.warn("No avatar found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp get_name(%Auth{info: %{name: name}})
       when name not in [nil, ""] do
    name
  end

  defp get_name(%Auth{
         info: %{first_name: first, last_name: last}
       })
       when first not in ["", nil] or last not in ["", nil] do
    [first, last]
    |> Enum.filter(&(&1 != nil and &1 != ""))
    |> Enum.join(" ")
  end

  defp get_name(%Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp get_name(%Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp get_name(auth) do
    Logger.warn("No name found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp get_nickname(%Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp get_nickname(auth) do
    Logger.warn("No nickname found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp get_email(%Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp get_email(auth) do
    Logger.warn("No email found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end
end
