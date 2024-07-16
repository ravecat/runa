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
end