defmodule Runa.Locales.Locale do
  @moduledoc """
  Schema for the locale entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Projects.Project, Languages.Language}

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
