defmodule Runa.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :title, :string
      add :owner_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
