defmodule RunaWeb.TranslationJSONAPI do
  @moduledoc """
  API response for translation resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.Translation
end
