defmodule Runa.Repo.Migrations.AddLanguageIdToTranslation do
  use Ecto.Migration

  def change do
    alter table(:translations) do
      add :language_id, references(:languages, on_delete: :restrict)
    end

    create index(:translations, [:language_id])
  end
end
