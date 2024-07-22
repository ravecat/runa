defmodule RunaWeb.Serializers.Team do
  @moduledoc """
  Response serializer for team resources
  """
  use JSONAPI.View

  alias RunaWeb.Formatters
  alias RunaWeb.Serializers

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
      projects: Serializers.Project
    ]

  def inserted_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.inserted_at)
  end

  def updated_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.updated_at)
  end

  def sortable, do: Enum.map(fields(), &Atom.to_string(&1))
  def filterable, do: Enum.map(fields(), &Atom.to_string(&1))
end
