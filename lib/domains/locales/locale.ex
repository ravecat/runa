defmodule Runa.Locales.Locale do
  @moduledoc """
  Schema for the locale entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.Languages.Language
  alias Runa.Projects.Project

  schema "locales" do
    belongs_to :project, Project
    belongs_to :language, Language

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(locale, attrs) do
    locale
    |> cast(attrs, [:project_id, :language_id])
    |> validate_required([:project_id, :language_id])
  end
end
