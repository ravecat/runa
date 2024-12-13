defmodule Mix.Tasks.Seed.Data do
  @moduledoc """
  Seed data to the database.
  """

  use Mix.Task

  import Runa.Factory

  alias Runa.Languages.Language
  alias Runa.Repo

  require Logger

  @requirements ["app.start"]
  @email Application.compile_env(:runa, :authentication)[:email]

  def run(_args) do
    Logger.info("Starting to seed development data...")

    case Repo.aggregate(Language, :count) do
      0 ->
        Logger.info("No languages found. Running languages seed...")
        Mix.Task.run("seed.languages")

      count ->
        Logger.info("Found #{count} languages")
    end

    Repo.query!(
      "TRUNCATE TABLE users, teams, contributors, projects, locales, keys, translations, tokens CASCADE"
    )

    user = insert(:user, email: @email)

    languages = Repo.all(Language)

    teams =
      1..5
      |> Enum.map(fn _i ->
        team = insert(:team)
        insert(:contributor, user: user, team: team)

        projects = insert_list(3, :project, team: team)

        {team, projects}
      end)

    teams
    |> Enum.flat_map(fn {_, projects} -> projects end)
    |> Enum.each(fn project ->
      languages
      |> Enum.take_random(Enum.random(10..25))
      |> Enum.each(fn language ->
        insert(:locale, project: project, language: language)
      end)
    end)

    insert_list(3, :token, user: user)

    Logger.info("Finished seeding development data")
  end
end
