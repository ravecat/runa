defmodule Runa.Repo.Migrations.RenameWallsCodeToWalsCode do
  use Ecto.Migration

  def change do
    rename table(:languages), :walls_code, to: :wals_code

    drop unique_index(:languages, [:iso_code])
    drop unique_index(:languages, [:glotto_code])
  end
end
