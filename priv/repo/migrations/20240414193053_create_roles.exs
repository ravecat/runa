defmodule Runa.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add :title, :string

      timestamps(type: :utc_datetime)
    end
  end
end
