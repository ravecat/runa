defmodule Runa.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def up do
    create table(:teams) do
      add :title, :string
      add :owner_id, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end

  def down do
    drop table(:teams)
  end
end
