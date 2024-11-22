defmodule Runa.Tokens do
  @moduledoc """
  The Tokens context.
  """

  use Runa, :context

  alias Runa.Tokens.Token

  @doc """
  Return token
  """

  def get(token) when is_binary(token) do
    case Repo.get_by(Token, hash: hash(token)) do
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
  def index(user) do
    Token
    |> where(user_id: ^user.id)
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
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Token{} = token, attrs) do
    token
    |> Token.update_changeset(attrs)
    |> Repo.update()
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
end
