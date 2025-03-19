defmodule Runa.Files.File do
  @moduledoc """
  File schema
  """
  use Runa, :schema

  alias Runa.Keys.Key
  alias Runa.Projects.Project

  @extensions [:json]

  schema "files" do
    field :filename, :string
    field :extension, Ecto.Enum, values: @extensions, virtual: true
    belongs_to :project, Project
    has_many :keys, Key

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :project_id])
    |> validate_required([:filename])
    |> foreign_key_constraint(:project_id)
    |> cast_assoc(:keys)
  end

  def extensions, do: @extensions
end
