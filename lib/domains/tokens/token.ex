defmodule Runa.Tokens.Token do
  @moduledoc """
  The api tokens  schema.
  """
  use Runa, :schema

  alias Runa.Accounts.User
  alias Runa.Tokens

  @access_levels [write: 4, read: 2, suspended: 1]

  schema "tokens" do
    field :hash, :string
    field :token, :string, virtual: true
    field :access, Ecto.Enum, values: @access_levels
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:access, :user_id, :token])
    |> validate_required([:access, :user_id, :token])
    |> assoc_constraint(:user)
    |> put_hash()
  end

  def update_changeset(token, attrs) do
    token
    |> cast(attrs, [:access])
    |> validate_required([:access])
  end

  defp put_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{token: token}} ->
        put_change(changeset, :hash, Tokens.hash(token))

      _ ->
        changeset
    end
  end

  def access_levels, do: @access_levels
end
