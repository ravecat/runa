defmodule MyApp.Repo.Migrations.CreateTranslations do
  use Ecto.Migration

  def change do
    create table(:translations) do
      add :key_id, references(:keys, on_delete: :delete_all), null: false
      add :translation, :text

      timestamps(type: :utc_datetime)
    end
  end
end
