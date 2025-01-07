defmodule Runa.Repo.Migrations.AddTitleToToken do
  use Ecto.Migration

  def up do
    alter table(:tokens) do
      add :title, :string, null: false, default: "Untitled"
    end
  end

  def down do
    alter table(:tokens) do
      remove :title
    end
  end
end
