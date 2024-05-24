defmodule MyApp.Repo.Migrations.CreateLocales do
  use Ecto.Migration

  def change do
    create table(:locales) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :language_id, references(:languages, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:locales, [:project_id])
    create index(:locales, [:language_id])
    create unique_index(:locales, [:project_id, :language_id])
  end
end
