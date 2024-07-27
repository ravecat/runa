defmodule RunaWeb.Serializers.Project do
  @moduledoc """
  Response serializer for project resources
  """
  use RunaWeb, :serializer

  def type, do: "projects"

  def fields,
    do: [
      :name,
      :description,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]

  def relationships,
    do: [
      keys: Serializers.Key
    ]
end
