defmodule Runa.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Teams.Team

  @doc """
  Returns the list of users.

  ## Examples

      iex> index()
      [%User{}, ...]

  """
  def index do
    User
    |> Repo.all()
    |> Repo.preload([:contributors, :teams])
  end

  @doc """
  Gets a single user.

  Returns {:error, %Ecto.NoResultsError{}} if the User does not exist.

  ## Examples

      iex> get(123)
      {:ok, %User{}}

      iex> get(456)
      {:error, %Ecto.NoResultsError{}}

  """
  def get(id) do
    query =
      from u in User,
        where: u.id == ^id,
        preload: [:teams]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  def get_by(attrs \\ []) do
    Repo.get_by(User, attrs)
    |> Repo.preload(:teams)
  end

  def get_user_by_id(nil), do: nil

  def get_user_by_id(id) do
    case get(id) do
      {:ok, user} -> user
      _ -> nil
    end
  end

  @doc """
  Creates or finds user.
  """
  def create_or_find(attrs \\ %{}) do
    with %Ecto.Changeset{valid?: true} <- User.changeset(%User{}, attrs),
         nil <- Repo.get_by(User, email: attrs.email),
         {:ok, %{user: %User{} = user}} <-
           Multi.new()
           |> Multi.insert(:user, User.changeset(%User{}, attrs))
           |> Multi.insert(:team, fn %{user: user} ->
             Team.changeset(%Team{}, %{title: "#{user.name}'s Team"})
           end)
           |> Multi.insert(:contributor, fn %{
                                              user: user,
                                              team: team
                                            } ->
             Contributor.changeset(%Contributor{}, %{
               user_id: user.id,
               team_id: team.id,
               role: :owner
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

      iex> update(%User{} = user, %{field: new_value})
      {:ok, %User{}}

      iex> update(%User{} = user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete(%User{} = user)
      {:ok, %User{}}

      iex> delete(%User{} = user)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change(%User{} = user, %{field: new_value})
      %Ecto.Changeset{data: %User{}}

  """
  def change(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
