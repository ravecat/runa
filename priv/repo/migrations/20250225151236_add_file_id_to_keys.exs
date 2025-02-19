defmodule Runa.Repo.Migrations.AddFileIdToKeys do
  use Ecto.Migration

  def up do
    alter table(:keys) do
      add :file_id, references(:files, on_delete: :delete_all)
    end

    create index(:keys, [:file_id])
  end

  def down do
    alter table(:keys) do
      remove :file_id
    end
  end
end
