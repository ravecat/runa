defmodule MyApp.Repo.Migrations.CreateKeys do
  use Ecto.Migration

  def change do
    create table(:keys) do
      add :name, :string, null: false
      add :description, :text
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end
  end
end
