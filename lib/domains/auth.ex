defmodule Runa.Auth do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Poison

  alias Ueberauth.Auth

  alias Runa.{Accounts, Roles, TeamRoles, Teams, Repo}

  @roles Application.compile_env(:runa, :permissions)

  def find_or_create(%Auth{provider: :auth0} = auth) do
    with uid when not is_nil(uid) <- auth.uid,
         email when not is_nil(email) <- fetch_email(auth),
         user when is_nil(user) <-
           Repo.get_by(Accounts.User, email: email),
         {:ok, new_user} <-
           Accounts.create_user(%{
             uid: auth.uid,
             name: fetch_name(auth),
             avatar: fetch_avatar(auth),
             nickname: fetch_nickname(auth),
             email: fetch_email(auth)
           }),
         {:ok, new_team} <-
           Teams.create_team(%{
             title: "#{new_user.name}'s Team"
           }),
         %Roles.Role{} = role <-
           Repo.get_by(Roles.Role,
             title: @roles[:owner]
           ),
         {:ok, %TeamRoles.TeamRole{}} <-
           Ecto.build_assoc(new_user, :team_roles, %{
             team_id: new_team.id,
             role_id: role.id,
             user_id: new_user.id
           })
           |> Repo.insert() do
      user = Repo.preload(new_user, [:teams, :team_roles])

      {:ok, user}
    else
      %Accounts.User{} = user ->
        user = Repo.preload(user, [:teams, :team_roles])

        {:ok, user}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:error, "Failed to create user"}

      _err ->
        {:error, "Required authentication information is missing."}
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
    Logger.warn("No avatar found in auth info!")
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
    Logger.warn("No name found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_nickname(%Auth{info: %{nickname: nickname}})
       when nickname not in [nil, ""] do
    nickname
  end

  defp fetch_nickname(auth) do
    Logger.warn("No nickname found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end

  defp fetch_email(%Auth{info: %{email: email}})
       when email not in [nil, ""] do
    email
  end

  defp fetch_email(auth) do
    Logger.warn("No email found in auth info!")
    Logger.debug(Poison.encode!(auth))

    nil
  end
end
