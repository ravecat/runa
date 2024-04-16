defmodule Runa.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :uid, :string
    field :name, :string
    field :avatar, :string
    field :nickname, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :uid, :avatar])
    |> validate_required([:name, :uid])
  end
end
