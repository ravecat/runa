defmodule Runa.Keys.Key do
  @moduledoc """
  Schema for the key entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Projects.Project, Translations.Translation}

  schema "keys" do
    field :name, :string
    field :description, :string
    belongs_to :project, Project
    has_many :translations, Translation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:name, :description, :project_id])
    |> validate_required([:name, :description, :project_id])
  end
end