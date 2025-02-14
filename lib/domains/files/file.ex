defmodule Runa.Files.File do
  @moduledoc """
  File schema
  """
  use Runa, :schema

  alias Runa.Projects.Project

  @extensions [:json]

  schema "files" do
    field :filename, :string
    field :status, Ecto.Enum, values: @extensions, virtual: true
    belongs_to :project, Project

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :project_id])
    |> validate_required([:filename, :project_id])
    |> foreign_key_constraint(:project_id)
  end

  def extensions, do: @extensions
end
