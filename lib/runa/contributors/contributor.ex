defmodule Runa.Contributors.Contributor do
  @moduledoc """
  Schema representing the relationship between a user and a team with associated role.
  """
  use Runa, :schema

  alias Runa.Accounts
  alias Runa.Teams

  @owner [owner: 8]
  @roles [admin: 4, editor: 2, viewer: 1]

  typed_schema "contributors" do
    field :role, Ecto.Enum, values: @owner ++ @roles
    belongs_to :user, Accounts.User
    belongs_to :team, Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contributor, attrs) do
    contributor
    |> cast(attrs, [:user_id, :team_id, :role])
    |> validate_required([:role])
    |> assoc_constraint(:user)
    |> assoc_constraint(:team)
  end

  def roles, do: @roles
end
