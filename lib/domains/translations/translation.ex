defmodule Runa.Translations.Translation do
  @moduledoc """
  Schema for the translation entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.Keys.Key

  schema "translations" do
    field :translation, :string
    belongs_to :key, Key

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(translation, attrs) do
    translation
    |> cast(attrs, [:translation, :key_id])
    |> validate_required([:key_id])
    |> foreign_key_constraint(:key_id)
  end
end
