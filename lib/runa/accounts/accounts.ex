defmodule Runa.Accounts do
  @moduledoc """
  The Accounts context.
  """

  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Contributors
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
  def get(nil), do: {:error, %Ecto.NoResultsError{}}

  def get(id) do
    query = from u in User, where: u.id == ^id, preload: [:teams]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  def get_by(attrs \\ []) do
    Repo.get_by(User, attrs)
  end

  @doc """
  Creates or finds user.
  """
  def create_or_find(attrs \\ %{}) do
    with %Ecto.Changeset{valid?: true} <- change(%User{}, attrs),
         nil <- Repo.get_by(User, email: attrs.email),
         {:ok, %{user: %User{} = user}} <-
           Multi.new()
           |> Multi.insert(:user, change(%User{}, attrs))
           |> Multi.insert(:team, &%Team{title: "#{&1.user.name}'s Team"})
           |> Multi.insert(
             :contributor,
             &Contributors.change(%Contributor{}, %{
               user_id: &1.user.id,
               team_id: &1.team.id,
               role: :owner
             })
           )
           |> Repo.transaction() do
      {:ok, user}
    else
      %User{} = user -> {:ok, user}
      %Ecto.Changeset{} = changeset -> {:error, changeset}
      {:error, _, reason, _} -> {:error, reason}
    end
    |> broadcast(:account_created)
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
    |> broadcast(:account_updated)
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
  def change(user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def subscribe do
    PubSub.subscribe(User.__schema__(:source))
  end

  def subscribe(user_id) when is_integer(user_id) do
    PubSub.subscribe("#{User.__schema__(:source)}:#{user_id}")
  end

  defp broadcast({:ok, %User{} = data}, event) do
    PubSub.broadcast("#{User.__schema__(:source)}:#{data.id}", {event, data})

    {:ok, data}
  end

  defp broadcast({:error, reason}, _event), do: {:error, reason}
end
