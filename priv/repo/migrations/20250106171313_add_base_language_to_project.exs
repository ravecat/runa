defmodule Runa.Repo.Migrations.AddBaseLanguageToProject do
  use Ecto.Migration

  def up do
    alter table(:projects) do
      add :base_language_id, references(:languages)
    end

    execute """
      UPDATE projects p
      SET base_language_id = (
        SELECT l.id
        FROM languages l
        JOIN locales loc ON loc.language_id = l.id
        WHERE loc.project_id = p.id
        LIMIT 1
      )
    """

    execute "ALTER TABLE projects ALTER COLUMN base_language_id SET NOT NULL"

    create index(:projects, [:base_language_id])
  end

  def down do
    alter table(:projects) do
      remove :base_language_id
    end
  end
end
