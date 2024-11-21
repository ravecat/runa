defmodule Runa.Repo.Migrations.RecreateContributorConstraints do
  use Ecto.Migration

  def up do
    drop_if_exists constraint(:contributors, "team_roles_user_id_fkey")
    drop_if_exists constraint(:contributors, "team_roles_team_id_fkey")
  end

  def down do
    drop_if_exists constraint(:contributors, "contributors_user_id_fkey")
    drop_if_exists constraint(:contributors, "contributors_team_id_fkey")

    alter table(:contributors) do
      modify :user_id, references(:users, on_delete: :delete_all)
      modify :team_id, references(:teams, on_delete: :delete_all)
    end
  end
end
