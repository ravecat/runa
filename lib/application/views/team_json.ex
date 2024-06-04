defmodule RunaWeb.TeamJSONAPI do
  @moduledoc """
  API response for teams
  """
  alias RunaWeb.TeamSerializer

  import JSONAPI.Serializer

  @doc """
  Serializes a list of teams
  """
  def index(%{data: data, conn: conn}) do
    TeamSerializer
    |> serialize(data, conn)
    |> Jason.encode!()
  end
end
