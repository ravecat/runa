defmodule Runa.Repo.Migrations.AddUserIdToTokens do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:tokens, [:user_id])
  end
end
