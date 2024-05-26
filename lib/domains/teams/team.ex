defmodule Runa.Teams.Team do
  @moduledoc """
  The schema for teams, which are groups of users
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Accounts.User, Contributors.Contributor, Projects.Project}

  schema "teams" do
    field :title, :string
    has_many :contributors, Contributor
    has_many :projects, Project
    many_to_many :users, User, join_through: Contributor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
