defmodule Runa.Languages.Language do
  @moduledoc """
  The language schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :walls_code, :string
    field :iso_code, :string
    field :glotto_code, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:walls_code, :iso_code, :glotto_code, :title])
    |> validate_required([:walls_code, :title])
    |> unique_constraint(:walls_code)
    |> unique_constraint(:iso_code)
    |> unique_constraint(:glotto_code)
  end
end
