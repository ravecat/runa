defmodule Runa.Paginator do
  @moduledoc """
  Paginator module for offset, page and cursor based pagination
  """
  alias Ecto.Queryable
  import Ecto.Query
  alias Runa.Repo

  @type page_number_params :: %{:number => integer(), :size => integer()}

  @type offset_params :: %{:offset => integer(), :limit => integer()}

  @type cursor_params :: %{
          :size => integer(),
          optional(:after) => String.t(),
          optional(:before) => String.t()
        }

  @type opts :: %{
          optional(:sort) => [{atom(), atom()}],
          optional(:filter) => [{atom(), term()}],
          optional(:page) =>
            page_number_params() | offset_params() | cursor_params()
        }

  @spec paginate(Queryable.t(), opts, [Flop.option()]) ::
          {:ok, {[any], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def paginate(query, %{page: page} = params, opts) when map_size(page) > 0 do
    sort = Map.get(params, :sort, [])
    filter = Map.get(params, :filter, [])
    {order_direction, order_by} = Enum.unzip(sort)

    flop = %{
      order_by: order_by,
      order_direction: order_direction,
      filters: filter
    }

    page_flop = map_to_flop(page)

    Flop.validate_and_run(query, Map.merge(flop, page_flop), opts)
  end

  def paginate(query, params, _opts) do
    sort = Map.get(params, :sort, [])
    filter = Map.get(params, :filter, [])

    data = query |> where(^filter) |> order_by(^sort) |> Repo.all()

    {:ok, {data, %{}}}
  end

  defp map_to_flop(%{"number" => number, "size" => size}) do
    %{page: number, page_size: size}
  end

  defp map_to_flop(%{"offset" => offset, "limit" => limit}) do
    %{offset: offset, limit: limit}
  end

  defp map_to_flop(%{"after" => after_cursor, "size" => size}) do
    %{after: after_cursor, first: size}
  end

  defp map_to_flop(%{"before" => before_cursor, "size" => size}) do
    %{before: before_cursor, last: size}
  end

  defp map_to_flop(%{"size" => size}) do
    %{first: size}
  end

  defp map_to_flop(page) do
    page
  end
end
