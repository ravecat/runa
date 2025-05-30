defmodule RunaWeb.Plugs.Authentication do
  @moduledoc """
  Plug for protecting routes that require authentication.
  """
  import Plug.Conn

  use RunaWeb, :controller

  require Logger
  require Poison

  alias Runa.Accounts
  alias Runa.Services.Avatar

  def call(conn, _) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)

      user = user_id && get_user_from_session(user_id) ->
        put_current_user(conn, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  defp get_user_from_session(user_id) do
    case Accounts.get(user_id) do
      {:ok, user} -> user
      _ -> nil
    end
  end

  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  def authenticate_by_auth_data(%Ueberauth.Auth{} = auth) do
    Accounts.create_or_find(%{
      uid: auth.uid,
      email: fetch_email(auth),
      name: fetch_name(auth),
      nickname: fetch_nickname(auth),
      avatar: fetch_avatar(auth)
    })
    |> case do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_avatar(auth) do
    auth
    |> fetch_name()
    |> Avatar.generate_url(style: :thumbs)
  end

  defp fetch_name(%Ueberauth.Auth{info: %{name: name}})
       when name not in [nil, ""] do
    name
  end

  defp fetch_name(%Ueberauth.Auth{info: %{first_name: first, last_name: last}})
       when first not in ["", nil] or last not in ["", nil] do
    [first, last]
    |> Enum.filter(&(&1 != nil and &1 != ""))
    |> Enum.join(" ")
  end

  defp fetch_name(%Ueberauth.Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp fetch_name(%Ueberauth.Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp fetch_name(auth) do
    Logger.debug("No name found in auth info!")
    Logger.debug(Poison.encode!(auth))

    "Anonymous"
  end

  defp fetch_nickname(%Ueberauth.Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp fetch_nickname(auth) do
    Logger.debug("No nickname found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_email(%Ueberauth.Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp fetch_email(auth) do
    Logger.debug("No email found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end
end
