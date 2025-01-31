defmodule Runa.Projects.Project do
  @moduledoc """
  Schema for the projects entity.
  """
  use Runa, :schema

  alias Runa.Files.File
  alias Runa.Keys.Key
  alias Runa.Languages.Language
  alias Runa.Languages.Locale
  alias Runa.Teams.Team

  schema "projects" do
    field :name, :string
    field :description, :string
    has_many :files, File
    has_many :keys, Key
    belongs_to :team, Team
    belongs_to :base_language, Language

    many_to_many :languages, Language,
      join_through: Locale,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:name, :description, :team_id, :base_language_id])
    |> validate_required([:name, :team_id, :base_language_id])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:base_language_id)
  end
end
