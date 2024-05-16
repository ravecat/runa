defmodule Runa.Repo.Migrations.AddTokenToTeam do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :token, :string, null: false
      modify :title, :string, null: false
    end
  end
end
