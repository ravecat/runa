defmodule MyApp.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token_id, references(:tokens, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:user_tokens, [:user_id, :token_id])
  end
end
