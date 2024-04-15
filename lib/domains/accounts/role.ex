defmodule Runa.Accounts.Role do
  @moduledoc """
  Role schema for accounts.

  Available roles: owner (default), admin, editor, viewer.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @valid_roles ["owner", "admin", "editor", "reader"]

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> validate_inclusion(:title, @valid_roles)
  end
end
