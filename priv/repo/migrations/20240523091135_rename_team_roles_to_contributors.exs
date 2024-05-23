defmodule MyApp.Repo.Migrations.RenameTeamRolesToContributors do
  use Ecto.Migration

  def change do
    rename table(:team_roles), to: table(:contributors)
  end
end
