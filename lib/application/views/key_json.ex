defmodule RunaWeb.KeyJSONAPI do
  @moduledoc """
  API response for key resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.Key
end
