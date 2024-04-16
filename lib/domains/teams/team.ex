defmodule Runa.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset

  schema "teams" do
    field :title, :string
    field :owner_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:title, :owner_id])
    |> validate_required([:title, :owner_id])
  end
end
