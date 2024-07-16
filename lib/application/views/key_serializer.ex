defmodule RunaWeb.KeySerializer do
  @moduledoc """
  Response serializer for project key resources
  """
  use JSONAPI.View

  alias RunaWeb.Formatters

  def type, do: "keys"

  def fields,
    do: [
      :name,
      :description,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]

  def inserted_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.inserted_at)
  end

  def updated_at_timestamp(data, _conn) do
    Formatters.format_datetime_to_timestamp(data.updated_at)
  end
end