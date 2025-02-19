defmodule Runa.Repo.Migrations.RemoveProjectIdFromKeys do
  use Ecto.Migration

  def up do
    alter table(:keys) do
      remove :project_id
    end
  end

  def down do
    alter table(:keys) do
      add :project_id, references(:projects, on_delete: :nothing), null: false
    end
  end
end
