defmodule Runa.Auth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  def find_or_create(%Auth{provider: :auth0} = auth) do
    Logger.debug("Auth0 auth: " <> Poison.encode!(auth))

    {:ok,
     %{uid: auth.uid, name: get_name(auth), avatar: get_avatar(auth), nickname: get_nickname(auth)}}
  end

  defp get_avatar(%Auth{info: %{urls: %{avatar_url: image}}}), do: image

  defp get_avatar(%Auth{info: %{image: image}}), do: image

  defp get_avatar(%Auth{provider: provider} = auth) do
    Logger.warn(provider <> " needs to find an avatar URL!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp get_name(%Auth{info: %{name: name}}) when name not in [nil, ""] do
    name
  end

  defp get_name(%Auth{info: %{first_name: first, last_name: last}})
       when first not in ["", nil] or last not in ["", nil] do
    [first, last]
    |> Enum.filter(&(&1 != nil and &1 != ""))
    |> Enum.join(" ")
  end

  defp get_name(%Auth{info: %{nickname: nickname}}) when nickname not in [nil, ""] do
    nickname
  end

  defp get_name(auth) do
    Logger.warn("No name found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp get_nickname(%Auth{info: %{nickname: nickname}}) when nickname not in [nil, ""] do
    nickname
  end

  defp get_nickname(auth) do
    Logger.warn("No nickname found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end
end
