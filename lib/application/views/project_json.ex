defmodule RunaWeb.ProjectJSONAPI do
  @moduledoc """
  API response for project resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.Project
end
