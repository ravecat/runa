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

    many_to_many :languages, Language,
      join_through: Locale,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:name, :description, :team_id])
    |> validate_required([:name, :team_id])
    |> foreign_key_constraint(:team_id)
    |> put_assoc(:languages, parse_languages(attrs))
  end

  defp parse_languages(%{"languages" => languages}) when is_list(languages) do
    Language
    |> where([l], l.wals_code in ^languages)
    |> Repo.all()
  end

  defp parse_languages(%{"languages" => languages}) when is_binary(languages) do
    Language
    |> where([l], l.wals_code in ^[languages])
    |> Repo.all()
  end

  defp parse_languages(_), do: []
end
