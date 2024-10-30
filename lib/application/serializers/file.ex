defmodule RunaWeb.Serializers.File do
  @moduledoc """
  Response serializer for file resources
  """
  use RunaWeb, :serializer

  def type, do: "files"

  def fields,
    do: [
      :filename,
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
