defmodule Runa.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Repo
  alias Runa.Roles.Role
  alias Runa.Teams.Team

  alias Ecto.Multi

  @roles Application.compile_env(:runa, :permissions)

  @doc """
  Returns the list of users.

  ## Examples

      iex> get_users()
      [%User{}, ...]

  """
  def get_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by(attrs \\ []) do
    Repo.get_by(User, attrs)
    |> Repo.preload(:teams)
  end

  @doc """
  Creates or finds user.
  """
  def create_or_find_user(attrs \\ %{}) do
    with %Ecto.Changeset{valid?: true} <- User.changeset(%User{}, attrs),
         nil <- Repo.get_by(User, email: attrs.email),
         {:ok, %{user: %User{} = user}} <-
           Multi.new()
           |> Multi.one(
             :role,
             from(r in Role, where: r.title == ^@roles[:owner])
           )
           |> Multi.insert(:user, User.changeset(%User{}, attrs))
           |> Multi.insert(:team, fn %{user: user} ->
             Team.changeset(%Team{}, %{title: "#{user.name}'s Team"})
           end)
           |> Multi.insert(:contributor, fn %{
                                              user: user,
                                              team: team,
                                              role: role
                                            } ->
             Contributor.changeset(%Contributor{}, %{
               user_id: user.id,
               team_id: team.id,
               role_id: role.id
             })
           end)
           |> Repo.transaction() do
      {:ok, user}
    else
      %User{} = user ->
        {:ok, user}

      %Ecto.Changeset{} = changeset ->
        {:error, changeset}

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
