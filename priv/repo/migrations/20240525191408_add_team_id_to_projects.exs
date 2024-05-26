defmodule MyApp.Repo.Migrations.AddTeamIdToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :team_id, references(:teams, on_delete: :delete_all), null: false
    end
  end
end
