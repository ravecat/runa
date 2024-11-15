defmodule Mix.Tasks.Seed.Data do
  @moduledoc """
  Seed data to the database.
  """

  use Mix.Task

  import Runa.Factory

  alias Runa.Repo

  require Logger

  @requirements ["app.start"]
  @email Application.compile_env(:runa, :authentication)[:email]

  def run(_args) do
    Logger.info("Starting to seed development data...")

    Repo.query!(
      "TRUNCATE TABLE users, teams, contributors, projects, locales, keys, translations, tokens CASCADE"
    )

    insert(:user, email: @email)
  end
end
