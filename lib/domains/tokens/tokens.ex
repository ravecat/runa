defmodule Runa.Tokens do
  @moduledoc """
  The Tokens context.
  """

  use Runa, :context

  alias Runa.Accounts.User
  alias Runa.Tokens.Token

  @doc """
  Return token
  """
  def get(id) do
    query = from t in Token, where: t.id == ^id, preload: [:user]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  def get_by_token(token) do
    query = from t in Token, where: t.hash == ^hash(token), preload: [:user]

    case Repo.one(query) do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Return all tokens.

  ## Examples

      iex> index()
      [%Token{}, ...]

  """
  def index(%User{} = user) do
    Token
    |> where(user_id: ^user.id)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Creates a token.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Token{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Token{}
    |> change(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} -> {:ok, Repo.preload(data, :user)}
      error -> error
    end
    |> broadcast(:token_created)
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Token{} = token, attrs \\ %{}) do
    token
    |> Token.update_changeset(attrs)
    |> Repo.update()
    |> broadcast(:token_updated)
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete(token)
      {:ok, %Token{}}

      iex> delete(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Token{} = token) do
    Repo.delete(token)
  end

  def delete(id) do
    Repo.get_by(Token, id: id) |> Repo.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token changes.

  ## Examples

      iex> change(token)
      %Ecto.Changeset{data: %Token{}}

  """
  def change(%Token{} = token, attrs \\ %{}) do
    Token.changeset(token, attrs)
  end

  @doc """
  Generate a token for a user.
  """
  def generate do
    :crypto.strong_rand_bytes(24) |> Base.url_encode64(padding: false)
  end

  @doc """
  Generate a hash for a token.
  """
  def hash(token) when is_binary(token) do
    :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
  end

  def apply(token, attrs) do
    token
    |> change(attrs)
    |> Ecto.Changeset.apply_changes()
  end

  def subscribe do
    Phoenix.PubSub.subscribe(PubSub, Token.__schema__(:source))
  end

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(PubSub, "#{Token.__schema__(:source)}:#{user_id}")
  end

  defp broadcast({:ok, %Token{} = data}, event) do
    PubSub.broadcast(
      "#{Token.__schema__(:source)}:#{data.user.id}",
      {event, data}
    )

    {:ok, data}
  end

  defp broadcast({:error, reason}, _event), do: {:error, reason}
end
