defmodule RunaWeb.Serializers.Key do
  @moduledoc """
  Response serializer for project key resources
  """
  use RunaWeb, :serializer

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


  def relationships,
    do: [
      project: RunaWeb.Serializers.Project
    ]
end
