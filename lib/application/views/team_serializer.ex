defmodule RunaWeb.TeamSerializer do
  @moduledoc """
  Response serializer for team resources
  """
  use JSONAPI.View

  alias RunaWeb.Formatters
  alias RunaWeb.ProjectSerializer

  def type, do: "teams"

  def fields,
    do: [
      :title,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]

  def relationships,
    do: [
      projects: ProjectSerializer
    ]

  def inserted_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.inserted_at)
  end

  def updated_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.updated_at)
  end
end
