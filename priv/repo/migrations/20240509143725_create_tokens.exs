defmodule Runa.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :token, :string
      add :access, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
