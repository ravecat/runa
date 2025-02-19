defmodule Runa.Keys.Key do
  @moduledoc """
  Schema for the key entity.
  """
  use Runa, :schema

  alias Runa.Files.File
  alias Runa.Translations.Translation

  schema "keys" do
    field :name, :string
    field :description, :string
    belongs_to :file, File
    has_many :translations, Translation

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:name, :description, :file_id])
    |> validate_required([:name, :file_id])
  end
end
