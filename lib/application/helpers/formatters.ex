defmodule RunaWeb.Formatters do
  @moduledoc """
  Set of helper functions to format data
  """

  @spec format_datetime_to_timestamp(DateTime.t()) :: binary()
  def format_datetime_to_timestamp(dt) do
    dt
    |> DateTime.to_unix()
    |> Integer.to_string()
  end

  @spec format_datetime_to_view(DateTime.t()) :: binary()
  def format_datetime_to_view(dt) do
    Calendar.strftime(dt, "%b %d, %Y %I:%M %p")
  end
end
