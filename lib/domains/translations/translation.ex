defmodule Runa.Translations.Translation do
  @moduledoc """
  Schema for the translation entity.
  """
  use Runa, :schema

  alias Runa.Keys.Key
  alias Runa.Languages.Language

  @derive {
    Flop.Schema,
    sortable: [:translation, :inserted_at, :updated_at, :id],
    filterable: [:translation],
    default_order: %{
      order_by: [:inserted_at, :id],
      order_directions: [:desc, :asc]
    }
  }

  schema "translations" do
    field :translation, :string
    belongs_to :key, Key
    belongs_to :language, Language

    timestamps(type: :utc_datetime)
  end

  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:translation, :key_id, :language_id])
    |> validate_required([:translation, :language_id])
    |> foreign_key_constraint(:key_id)
    |> foreign_key_constraint(:language_id)
  end
end
