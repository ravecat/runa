defmodule Runa.Repo.Migrations.AddTokenToTeam do
  use Ecto.Migration

  def up do
    alter table(:teams) do
      modify :title, :string, null: false
    end
  end

  def down do
    alter table(:teams) do
      modify :title, :string, null: true
    end
  end
end
