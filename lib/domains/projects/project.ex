defmodule Runa.Projects.Project do
  @moduledoc """
  Schema for the projects entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.Files.File
  alias Runa.Keys.Key
  alias Runa.Languages.Language
  alias Runa.Locales.Locale
  alias Runa.Teams.Team

  schema "projects" do
    field :name, :string
    field :description, :string
    has_many :files, File
    has_many :keys, Key
    belongs_to :team, Team
    many_to_many :locales, Language, join_through: Locale

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description, :team_id])
    |> validate_required([:name, :team_id])
    |> foreign_key_constraint(:team_id)
  end
end
