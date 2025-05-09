defmodule Runa.Teams.Team do
  @moduledoc """
  The schema for team resource
  """

  use Runa, :schema

  alias Runa.Accounts.User
  alias Runa.Contributors.Contributor
  alias Runa.Projects.Project

  @derive {Flop.Schema,
           sortable: [:title, :inserted_at, :updated_at, :id],
           filterable: [:title],
           default_order: %{
             order_by: [:inserted_at, :id],
             order_directions: [:desc, :asc]
           }}

  defimpl Jason.Encoder, for: __MODULE__ do
    def encode(value, opts) do
      value
      |> Map.take([:id, :title, :inserted_at, :updated_at])
      |> Map.update(:inserted_at, nil, &dt_to_string/1)
      |> Map.update(:updated_at, nil, &dt_to_string/1)
      |> Jason.Encode.map(opts)
    end
  end

  typed_schema "teams" do
    field :title, :string
    has_many :projects, Project
    many_to_many :users, User, join_through: Contributor
    timestamps type: :utc_datetime
  end

  @doc false
  def changeset(data, attrs) do
    data
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> validate_length(:title, min: 3, max: 100)
  end
end
