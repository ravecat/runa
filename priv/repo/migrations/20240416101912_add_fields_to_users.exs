defmodule Runa.Repo.Migrations.AddFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :uid, :string, null: false
      add :nickname, :string
    end

    create unique_index(:users, [:uid])
  end
end
