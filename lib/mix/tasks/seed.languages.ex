defmodule Mix.Tasks.Seed.Languages do
  @moduledoc """
  Fetch languages data from a CSV file and seed the database.
  """

  use Mix.Task

  require Logger
  alias Runa.Languages.Language
  alias Runa.Repo

  @requirements ["app.start"]
  @url "https://gist.githubusercontent.com/ravecat/a47ca0ebf170f3dc00f17bc408d6aba1/raw/b2f1651fa9c2aea8c0c4d282c13fbee20bb00e8f/languages.csv"

  def run(_args) do
    case fetch_csv_data(@url) do
      {:ok, {{_, 200, _}, _headers, data}} ->
        handle_data(data)

      err ->
        IO.warn(err)
        raise FetchError
    end
  end

  defp fetch_csv_data(url) do
    :httpc.request(:get, {url, []}, [], body_format: :binary)
  end

  defp handle_data(data) do
    now = DateTime.truncate(DateTime.utc_now(), :second)

    languages =
      [data]
      |> CSV.decode(
        headers: [
          :wals_code,
          :iso_code,
          :glottocode,
          :Name
        ]
      )
      |> Stream.drop(1)
      |> Stream.map(fn {:ok,
                        %{
                          wals_code: wals_code,
                          iso_code: iso_code,
                          glottocode: glotto_code,
                          Name: title
                        }} ->
        %{
          wals_code: wals_code,
          iso_code: iso_code,
          glotto_code: glotto_code,
          title: title,
          inserted_at: now,
          updated_at: now
        }
      end)
      |> Enum.to_list()

    {count, _} =
      Repo.insert_all(
        Language,
        languages,
        on_conflict: {:replace_all_except, [:id, :wals_code]},
        conflict_target: [:wals_code]
      )

    Logger.info("#{count} languages inserted successfully")
  end
end

defmodule FetchError do
  defexception message: "Unable to fetch data"
end
