defmodule RunaWeb.ProjectJSONAPI do
  @moduledoc """
  API response for project resource
  """
  use RunaWeb.CommonJSON, serializer: RunaWeb.Serializers.Project
end
