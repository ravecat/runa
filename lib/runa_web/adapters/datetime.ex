defmodule RunaWeb.Adapters.DateTime do
  @moduledoc """
  Datetime adapter for serializing and deserializing datetime values
  """

  @spec dt_to_timestamp(DateTime.t()) :: binary()
  def dt_to_timestamp(dt) do
    dt
    |> DateTime.to_unix()
    |> Integer.to_string()
  end

  @spec dt_to_string(DateTime.t(), binary()) :: binary()
  def dt_to_string(dt, pattern \\ "%b %d, %Y %I:%M %p") do
    Calendar.strftime(dt, pattern)
  end
end
