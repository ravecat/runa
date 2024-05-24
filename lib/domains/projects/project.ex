defmodule Runa.Projects.Project do
  @moduledoc """
  Schema for the projects entity.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias Runa.{Files.File, Keys.Key}

  schema "projects" do
    field :name, :string
    field :description, :string
    has_many :files, File
    has_many :keys, Key

    timestamps(type: :utc_datetime)
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
  end
end
