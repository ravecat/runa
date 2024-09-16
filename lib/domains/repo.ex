defmodule Runa.Repo do
  use Ecto.Repo,
    otp_app: :runa,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  @spec check_missing_resources(Ecto.Schema.t(), [String.t()]) ::
          [String.t()]
  def check_missing_resources(schema, ids) do
    existing_ids =
      from(e in schema, where: e.id in ^ids, select: e.id)
      |> __MODULE__.all()
      |> Enum.map(&to_string/1)
      |> MapSet.new()

    ids
    |> MapSet.new()
    |> MapSet.difference(existing_ids)
    |> MapSet.to_list()
  end
end
