defmodule Runa.Repo.Migrations.CreateTeamRoles do
  use Ecto.Migration

  def up do
    create table(:team_roles) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)
      add :role_id, references(:roles, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:team_roles, [:user_id, :team_id, :role_id],
             name: :contributors_user_id_team_id_role_id_index
           )
  end

  def down do
    drop index(:team_roles, [:user_id, :team_id, :role_id],
           name: :contributors_user_id_team_id_role_id_index
         )

    drop table(:team_roles)
  end
end
