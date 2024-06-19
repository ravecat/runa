defmodule RunaWeb.TeamSerializer do
  @moduledoc """
  Response serializer for teams
  """
  use JSONAPI.View

  def fields,
    do: [
      :title,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]

  def type, do: "teams"

  def inserted_at_timestamp(data, _conn) do
    format_datetime_to_timestamp(data.inserted_at)
  end

  def updated_at_timestamp(data, _conn) do
    format_datetime_to_timestamp(data.updated_at)
  end

  defp format_datetime_to_timestamp(dt) do
    dt
    |> DateTime.to_unix()
    |> Integer.to_string()
  end
end
