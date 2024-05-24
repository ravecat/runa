defmodule Runa.Languages.Language do
  @moduledoc """
  The language schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Projects.Project, Locales.Locale}

  schema "languages" do
    field :wals_code, :string
    field :iso_code, :string
    field :glotto_code, :string
    field :title, :string
    many_to_many :projects, Project, join_through: Locale

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
