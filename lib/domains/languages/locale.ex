defmodule Runa.Languages.Locale do
  @moduledoc """
  Schema for the locale entity.
  """
  use Runa, :schema

  alias Runa.Languages.Language
  alias Runa.Projects.Project

  schema "locales" do
    belongs_to(:project, Project)
    belongs_to(:language, Language)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(locale, attrs) do
    locale
    |> cast(attrs, [:project_id, :language_id])
    |> validate_required([:project_id, :language_id])
    |> foreign_key_constraint(:project_id)
    |> unique_constraint([:project_id, :language_id])
  end
end
