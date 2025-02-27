defmodule Runa.Repo.Migrations.AddNotNullConstraintToTranslationsLanguageId do
  use Ecto.Migration

  def up do
    execute """
    UPDATE translations
    SET language_id = (
      SELECT id FROM languages
      ORDER BY id
      LIMIT 1
    )
    WHERE language_id IS NULL
    """

    alter table(:translations) do
      modify :language_id, :bigint, null: false
    end
  end

  def down do
    alter table(:translations) do
      modify :language_id, :bigint, null: true
    end
  end
end
