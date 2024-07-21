defmodule RunaWeb.TeamJSONAPI do
  @moduledoc """
  API response for team resource
  """
  use RunaWeb.CommonJSON, serializer: RunaWeb.Serializers.Team
end
