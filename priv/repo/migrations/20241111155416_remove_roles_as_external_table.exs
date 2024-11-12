defmodule Runa.Repo.Migrations.RemoveRolesAsExternalTable do
  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:contributors, [:user_id, :team_id, :role_id])

    alter table(:contributors) do
      remove :role_id
      add :role, :integer, null: false
    end

    drop_if_exists table(:roles)

    create index(:contributors, [:role])
  end

  def down do
    create table(:roles) do
      add :title, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:roles, [:title])

    alter table(:contributors) do
      remove :role
      add :role_id, references(:roles, on_delete: :delete_all)
    end

    create unique_index(:contributors, [:user_id, :team_id, :role_id])
  end
end
