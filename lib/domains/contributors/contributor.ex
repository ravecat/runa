defmodule Runa.Contributors.Contributor do
  @moduledoc """
  Schema representing the relationship between a user and a team with associated role.
  """
  use Runa, :schema

  alias Runa.Accounts
  alias Runa.Teams

  @roles [owner: 8, admin: 4, editor: 2, viewer: 1]

  schema "contributors" do
    field :role, Ecto.Enum, values: @roles

    belongs_to :user, Accounts.User
    belongs_to :team, Teams.Team

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contributor, attrs) do
    contributor
    |> cast(attrs, [
      :user_id,
      :team_id,
      :role
    ])
    |> validate_required([:user_id, :team_id, :role])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:team_id)
  end
end
