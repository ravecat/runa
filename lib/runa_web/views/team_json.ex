defmodule RunaWeb.TeamJSONAPI do
  @moduledoc """
  API response for team resource
  """
  use RunaWeb.JSONAPI.View, serializer: RunaWeb.Serializers.Team
end
