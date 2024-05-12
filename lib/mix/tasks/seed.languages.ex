defmodule Mix.Tasks.Seed.Languages do
  @moduledoc """
  Fetch languages data from a CSV file and seed the database.
  """

  use Mix.Task

  require Logger
  alias Runa.Repo
  alias Runa.Languages.Language

  @requirements ["app.start"]
  @url "https://gist.githubusercontent.com/ravecat/a47ca0ebf170f3dc00f17bc408d6aba1/raw/b2f1651fa9c2aea8c0c4d282c13fbee20bb00e8f/languages.csv"
  @headers [
    :wals_code,
    :iso_code,
    :glottocode,
    :Name
  ]

  def run(_args) do
    case fetch_csv_data(@url) do
      {:ok, {{_, 200, _}, _headers, data}} ->
        handle_data(data)

      err ->
        IO.warn(err)
        raise CsvRequestError
    end
  end

  defp fetch_csv_data(url) do
    :httpc.request(:get, {url, []}, [], body_format: :binary)
  end

  defp handle_data(data) do
    [data]
    |> CSV.decode(headers: @headers)
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
        title: title
      }
    end)
    |> Stream.each(&handle_row/1)
    |> Stream.run()
  end

  defp handle_row(params) do
    changeset = Language.changeset(%Language{}, params)

    case Repo.insert(changeset,
           on_conflict: {:replace_all_except, [:id, :wals_code]},
           conflict_target: :wals_code
         ) do
      {:ok, _language} ->
        Logger.info("Language inserted successfully")

      {:error, changeset} ->
        Logger.error(changeset)
    end
  end
end

defmodule CsvRequestError do
  defexception message: "Unable to fetch data"
end
