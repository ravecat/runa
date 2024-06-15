defmodule Runa.Auth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger

  alias Runa.Accounts
  alias Ueberauth.Auth
  require Poison

  def find_or_create(%Auth{provider: :auth0} = auth) do
    result =
      Accounts.create_or_find_user(%{
        uid: auth.uid,
        email: fetch_email(auth),
        name: fetch_name(auth),
        nickname: fetch_nickname(auth),
        avatar: fetch_avatar(auth)
      })

    case result do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_avatar(%Auth{info: %{urls: %{avatar_url: image}}})
       when image not in [nil, ""] do
    image
  end

  defp fetch_avatar(%Auth{info: %{image: image}})
       when image not in [nil, ""] do
    image
  end

  defp fetch_avatar(auth) do
    Logger.debug("No avatar found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_name(%Auth{info: %{name: name}})
       when name not in [nil, ""] do
    name
  end

  defp fetch_name(%Auth{
         info: %{first_name: first, last_name: last}
       })
       when first not in ["", nil] or last not in ["", nil] do
    [first, last]
    |> Enum.filter(&(&1 != nil and &1 != ""))
    |> Enum.join(" ")
  end

  defp fetch_name(%Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp fetch_name(%Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp fetch_name(auth) do
    Logger.debug("No name found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_nickname(%Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp fetch_nickname(auth) do
    Logger.debug("No nickname found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_email(%Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp fetch_email(auth) do
    Logger.debug("No email found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end
end
