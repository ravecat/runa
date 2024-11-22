defmodule Runa.Repo.Migrations.AddTokenConstraints do
  use Ecto.Migration

  def up do
    alter table(:tokens) do
      remove :token
      add :hash, :string, null: false
      modify :access, :integer, null: false
    end

    create unique_index(:tokens, [:hash])
  end

  def down do
    drop unique_index(:tokens, [:hash])

    alter table(:tokens) do
      add :token, :string, null: false
      remove :hash
    end
  end
end
