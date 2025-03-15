defmodule RunaWeb.Serializers.Language do
  @moduledoc """
  Response serializer for language resources
  """
  use RunaWeb, :serializer

  def type, do: "languages"

  def fields,
    do: [
      :inserted_at,
      :updated_at,
      :inserted_at_timestamp,
      :updated_at_timestamp,
      :title,
      :wals_code,
      :iso_code,
      :glotto_code
    ]
end
