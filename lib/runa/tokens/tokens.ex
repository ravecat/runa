defmodule Runa.Tokens do
  @moduledoc """
  The Tokens context.
  """

  use Runa, :context

  alias Runa.Tokens.Token

  @doc """
  Return token by id.

  ## Examples

      iex> get(scope, 1)
      {:ok, %Token{}}

      iex> get(scope, 123)
      {:error, %Ecto.NoResultsError{}}

  """
  @spec get(Scope.t(), non_neg_integer()) ::
          {:ok, Token.t()} | {:error, %Ecto.NoResultsError{}}
  def get(%Scope{} = scope, id) do
    from(t in Token,
      where: t.id == ^id and t.user_id == ^scope.current_user.id,
      preload: [:user]
    )
    |> Repo.one()
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Return token by x-apy-key header.

  ## Examples

    iex> get_by_api_key(scope, "token_hash")
    {:ok, %Token{}}

    iex> get_by_api_key(scope, "invalid_hash")
    {:error, %Ecto.NoResultsError{}}

  """
  @spec get_by_api_key(String.t()) ::
          {:ok, Token.t()} | {:error, %Ecto.NoResultsError{}}
  def get_by_api_key(x_api_key) do
    from(t in Token, where: t.hash == ^hash(x_api_key), preload: [:user])
    |> Repo.one()
    |> case do
      nil -> {:error, %Ecto.NoResultsError{}}
      data -> {:ok, data}
    end
  end

  @doc """
  Return all tokens.

  ## Examples

      iex> index(scope)
      [%Token{}, ...]

  """
  @spec index(Scope.t()) :: list(Token.t())
  def index(%Scope{} = scope) do
    from(t in Token,
      where: t.user_id == ^scope.current_user.id,
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  Creates a token.

  ## Examples

      iex> create(scope, %{field: value})
      {:ok, %Token{}}

      iex> create(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create(Scope.t(), map()) ::
          {:ok, Token.t()} | {:error, Ecto.Changeset.t()}
  def create(%Scope{} = scope, attrs \\ %{}) do
    %Token{}
    |> change(attrs)
    |> Repo.insert()
    |> case do
      {:ok, data} ->
        data = Repo.preload(data, :user)

        broadcast(scope, %Events.TokenCreated{data: data})

        {:ok, data}

      error ->
        error
    end
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update(scope, token, %{field: new_value})
      {:ok, %Token{}}

      iex> update(scope, token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update(Scope.t(), Token.t(), map()) ::
          {:ok, Token.t()} | {:error, Ecto.Changeset.t()}
  def update(%Scope{} = scope, %Token{} = token, attrs \\ %{}) do
    token
    |> Token.update_changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.TokenUpdated{data: data})
        {:ok, data}

      error ->
        error
    end
  end

  @doc """
  Deletes a token.

  ## Examples

      iex> delete(scope, token)
      {:ok, %Token{}}

      iex> delete(scope, token)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete(Scope.t(), Token.t()) ::
          {:ok, Token.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Scope{} = scope, %Token{} = token) do
    Repo.delete(token)
    |> case do
      {:ok, data} ->
        broadcast(scope, %Events.TokenDeleted{data: data})
        {:ok, data}

      error ->
        error
    end
  end

  def delete(%Scope{} = scope, id) do
    get(scope, id)
    |> case do
      {:ok, token} -> delete(scope, token)
      other -> other
    end
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

  def get_access_labels,
    do: Enum.map(Token.access_levels(), fn {label, _} -> {label, label} end)

  @doc """
  Generate a hash for a token.
  """
  def hash(token) when is_binary(token) do
    :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)
  end

  @spec subscribe(Scope.t()) :: :ok | {:error, term()}
  def subscribe(%Scope{} = scope) do
    PubSub.subscribe(topic(scope))
  end

  @spec broadcast(Scope.t(), term()) :: :ok | {:error, term()}
  defp broadcast(%Scope{} = scope, event) do
    Runa.PubSub.broadcast(topic(scope), event)
  end

  defp topic(scope),
    do: "#{Token.__schema__(:source)}:#{scope.current_user.id}"
end
