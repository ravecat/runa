defmodule Runa.Files.File do
  @moduledoc """
  File schema
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.Projects.Project

  schema "files" do
    field :filename, :string
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
end
