defmodule Runa.Auth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  def find_or_create(%Auth{provider: :auth0} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(%Auth{uid: uid} = auth) do
    %{id: uid, name: name_from_auth(auth), avatar: avatar_from_auth(auth)}
  end

  # github does it this way
  defp avatar_from_auth(%Auth{info: %{urls: %{avatar_url: image}}}), do: image

  # facebook does it this way
  defp avatar_from_auth(%Auth{info: %{image: image}}), do: image

  # default case if nothing matches
  defp avatar_from_auth(%Auth{provider: provider} = auth) do
    Logger.warn(provider <> " needs to find an avatar URL!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp name_from_auth(%Auth{info: %{name: name}}) when name not in [nil, ""] do
    name
  end

  defp name_from_auth(%Auth{info: %{first_name: first, last_name: last}})
       when first not in ["", nil] and last not in ["", nil] do
    [first, last]
    |> Enum.filter(&(&1 != nil and &1 != ""))
    |> Enum.join(" ")
  end

  defp name_from_auth(%Auth{info: %{nickname: nickname}}) when nickname not in [nil, ""] do
    nickname
  end

  defp name_from_auth(_) do
    Logger.warn("No name found in auth info!")

    "-"
  end
end
