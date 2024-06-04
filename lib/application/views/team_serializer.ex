defmodule RunaWeb.TeamSerializer do
  @moduledoc """
  Response serializer for teams
  """
  use JSONAPI.View, type: "teams"

  def fields do
    [
      :title,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]
  end

  def attributes(data, conn) do
    data
    |> Map.put(
      :inserted_at_timestamp,
      format_datetime_to_timestamp(data.inserted_at)
    )
    |> Map.put(
      :updated_at_timestamp,
      format_datetime_to_timestamp(data.updated_at)
    )
    |> Map.update!(:inserted_at, &format_datetime_to_string(&1))
    |> Map.update!(:updated_at, &format_datetime_to_string(&1))
    |> super(conn)
  end

  defp format_datetime_to_string(dt) do
    dt
    |> DateTime.to_string()
    |> String.replace("T", " ")
    |> String.replace("Z", "")
    |> Kernel.<>(" (Etc/UTC)")
  end

  defp format_datetime_to_timestamp(dt) do
    dt
    |> DateTime.to_unix()
    |> Integer.to_string()
  end
end
