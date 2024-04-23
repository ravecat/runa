defmodule Runa.Repo.Migrations.RemoveOwnerIdFromTeams do
  use Ecto.Migration

  def up do
    alter table(:teams) do
      remove :owner_id
    end
  end

  def down do
    alter table(:teams) do
      add :owner_id, references(:users, on_delete: :restrict), null: false
    end
  end
end
