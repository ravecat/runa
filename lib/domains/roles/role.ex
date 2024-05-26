defmodule Runa.Roles.Role do
  @moduledoc """
  Role schema for accounts.

  Available roles: owner (default), admin, editor, viewer.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Contributors.Contributor, Accounts.User}

  @valid_roles ["owner", "admin", "editor", "reader"]

  schema "roles" do
    field :title, :string
    has_many :contributors, Contributor
    many_to_many :users, User, join_through: Contributor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:title])
    |> unique_constraint(:title)
    |> validate_required([:title])
    |> validate_inclusion(:title, @valid_roles)
  end
end
