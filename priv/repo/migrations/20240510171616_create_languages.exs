defmodule Runa.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :walls_code, :string, null: false
      add :iso_code, :string
      add :glotto_code, :string
      add :title, :string, null: false

      timestamps()
    end

    create unique_index(:languages, [:walls_code])
    create unique_index(:languages, [:iso_code])
    create unique_index(:languages, [:glotto_code])
  end
end
