defmodule Runa.Repo.Migrations.AddConstraintsToContributors do
  use Ecto.Migration

  def up do
    alter table(:contributors) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :team_id, references(:teams, on_delete: :delete_all)
    end

    alter table(:contributors) do
      modify :user_id, :bigint, null: false
      modify :team_id, :bigint, null: false
      modify :role, :integer, null: false
    end

    create index(:contributors, [:user_id])
    create index(:contributors, [:team_id])
  end

  def down do
    drop index(:contributors, [:team_id])
    drop index(:contributors, [:user_id])

    alter table(:contributors) do
      modify :user_id, :bigint, null: true
      modify :team_id, :bigint, null: true
      modify :role, :integer, null: true
    end
  end
end
