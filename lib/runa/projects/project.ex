defmodule Runa.Projects.Project do
  @moduledoc """
  Schema for the projects entity.
  """
  use Runa, :schema

  alias Runa.Files.File
  alias Runa.Languages
  alias Runa.Languages.Language
  alias Runa.Languages.Locale
  alias Runa.Teams.Team

  typed_schema "projects" do
    field :name, :string
    field :description, :string
    field :base_language_title, :string, virtual: true
    field :language_titles, {:array, :string}, virtual: true
    has_many :files, File
    has_many :locales, Locale, on_replace: :delete
    belongs_to :team, Team
    belongs_to :base_language, Language

    many_to_many :languages, Language, join_through: Locale, on_replace: :delete

    timestamps type: :utc_datetime
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:name, :description, :team_id, :base_language_id])
    |> validate_required([:name, :team_id, :base_language_id])
    |> foreign_key_constraint(:team_id)
    |> foreign_key_constraint(:base_language_id)
    |> cast_assoc(:locales)
  end

  def form_changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [
      :name,
      :description,
      :team_id,
      :language_titles,
      :base_language_title
    ])
    |> validate_required([:name, :team_id, :base_language_title])
    |> foreign_key_constraint(:team_id)
    |> put_base_language()
    |> put_languages()
  end

  defp put_base_language(
         %{valid?: true, changes: %{base_language_title: title}} = changeset
       ) do
    case Languages.get_by(title: title) do
      %Language{id: id} when not is_nil(id) ->
        put_change(changeset, :base_language_id, id)

      _ ->
        add_error(changeset, :base_language_title, "is invalid")
    end
  end

  defp put_base_language(changeset), do: changeset

  defp put_languages(
         %{valid?: true, changes: %{language_titles: titles}} = changeset
       )
       when is_list(titles) do
    languages = Repo.all(from t in Language, where: t.title in ^titles)
    put_assoc(changeset, :languages, languages)
  end

  defp put_languages(changeset), do: changeset
end
