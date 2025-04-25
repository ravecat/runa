defmodule Runa.Repo.Migrations.AddInvitations do
  use Ecto.Migration

  def change do
    create table(:invitations) do
      add :email, :string, null: false
      add :role, :integer, null: false
      add :token, :string, null: false
      add :status, :integer, null: false
      add :expires_at, :utc_datetime
      add :team_id, references(:teams, on_delete: :delete_all), null: false
      add :invited_by_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:invitations, [:token], unique: true)
    create index(:invitations, [:team_id])
    create index(:invitations, [:email])
    create index(:invitations, [:status])
  end
end
