defmodule RunaWeb.Serializers.Team do
  @moduledoc """
  Response serializer for team resources
  """
  use RunaWeb, :serializer

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
    do: [projects: Serializers.Project]
end
