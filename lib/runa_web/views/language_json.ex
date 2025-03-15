defmodule RunaWeb.LanguageJSONAPI do
  @moduledoc """
  API response for language resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.Language
end
