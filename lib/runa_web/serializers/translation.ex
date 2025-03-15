defmodule RunaWeb.Serializers.Translation do
  @moduledoc """
  Response serializer for translation resources
  """
  use RunaWeb, :serializer

  def type, do: "translations"

  def fields,
    do: [
      :translation,
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp
    ]

  def relationships,
    do: [key: RunaWeb.Serializers.Key, language: RunaWeb.Serializers.Language]
end
