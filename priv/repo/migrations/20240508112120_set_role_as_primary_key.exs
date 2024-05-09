defmodule Runa.Repo.Migrations.SetRoleAsPrimaryKey do
  use Ecto.Migration

  def up do
    create unique_index(:roles, [:title])
  end

  def down do
    drop unique_index(:roles, [:title])
  end
end
