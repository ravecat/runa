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

    insert_list(3, :token, user: user)

    teams =
      1..5
      |> Enum.map(fn _i ->
        team = insert(:team)
        insert(:contributor, user: user, team: team)

        projects =
          insert_list(3, :project,
            team: team,
            base_language: Enum.random(languages)
          )

        {team, projects}
      end)

    projects =
      teams
      |> Enum.flat_map(fn {_, projects} -> projects end)
      |> Enum.map(fn project ->
        languages = Enum.take_random(languages, Enum.random(3..5))

        locales =
          Enum.map(languages, fn language ->
            insert(:locale, project: project, language: language)
          end)

        files = insert_list(Enum.random(1..2), :file, project: project)

        {project, locales, files}
      end)

    keys =
      Enum.map(projects, fn {project, _, files} ->
        keys =
          Enum.flat_map(files, fn file ->
            insert_list(Enum.random(2..4), :key, file: file)
          end)

        {project, keys}
      end)

    Enum.each(keys, fn {project, keys} ->
      Enum.each(keys, fn key ->
        insert_list(3, :translation, key: key, language: project.base_language)
      end)
    end)

    Logger.info("Finished seeding development data")
  end
end
