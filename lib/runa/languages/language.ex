defmodule Runa.Languages.Language do
  @moduledoc """
  The language schema.
  """
  use Runa, :schema

  alias Runa.Languages.Locale
  alias Runa.Projects.Project
  alias Runa.Translations.Translation

  @derive {Flop.Schema,
           sortable: [:title, :inserted_at, :updated_at, :id],
           filterable: [:title],
           default_order: %{
             order_by: [:inserted_at, :id],
             order_directions: [:desc, :asc]
           }}

  typed_schema "languages" do
    field :wals_code, :string
    field :iso_code, :string
    field :glotto_code, :string
    field :title, :string
    many_to_many :projects, Project, join_through: Locale
    has_many :translations, Translation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:wals_code, :iso_code, :glotto_code, :title])
    |> validate_required([:wals_code, :title])
    |> unique_constraint(:wals_code)
  end
end
