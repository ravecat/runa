defmodule Runa.Permissions.Role do
  @moduledoc """
  Role schema for accounts.

  Available roles: owner (default), admin, editor, viewer.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field :title, :string

    has_many :team_roles, Runa.Permissions.TeamRole

    many_to_many :users, Runa.Accounts.User,
      join_through: Runa.Permissions.TeamRole

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
