defmodule Runa.Teams.Team do
  @moduledoc """
  The schema for team resource
  """

  use Runa, :schema

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Projects.Project

  @derive {
    Flop.Schema,
    sortable: [:title, :inserted_at, :updated_at, :id],
    filterable: [:title],
    default_order: %{
      order_by: [:inserted_at, :id],
      order_directions: [:desc, :asc]
    }
  }

  typed_schema "teams" do
    field(:title, :string)
    has_many(:projects, Project)
    many_to_many(:users, User, join_through: Contributor)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
