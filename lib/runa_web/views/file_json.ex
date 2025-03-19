defmodule RunaWeb.FileJSONAPI do
  @moduledoc """
  API response for file resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.File
end
