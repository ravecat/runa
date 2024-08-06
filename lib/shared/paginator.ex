defmodule Runa.Paginator do
  @moduledoc """
  Paginator module for offset, page and cursor based pagination
  """
  alias Ecto.Queryable

  @type params :: %{
          optional(:sort) => [{atom(), atom()}],
          optional(:filter) => [any()],
          optional(:page) => map()
        }

  @spec paginate(Queryable.t(), params, [Flop.option()]) ::
          {:ok, {[any], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def paginate(query, params, opts \\ []) do
    sort = Map.get(params, :sort, [])
    filter = Map.get(params, :filter, [])
    page = Map.get(params, :page, %{})

    {order_direction, order_by} = Enum.unzip(sort)

    flop = %{
      order_by: order_by,
      order_direction: order_direction,
      filters: filter
    }

    page_flop = map_to_flop(page)

    Flop.validate_and_run(
      query,
      Map.merge(flop, page_flop),
      opts
    )
  end

  defp map_to_flop(%{"number" => number, "size" => size}) do
    %{
      page: number,
      page_size: size
    }
  end

  defp map_to_flop(%{"offset" => offset, "limit" => limit}) do
    %{
      offset: offset,
      limit: limit
    }
  end

  defp map_to_flop(%{"after" => after_cursor, "size" => size}) do
    %{
      after: after_cursor,
      first: size
    }
  end

  defp map_to_flop(%{"before" => before_cursor, "size" => size}) do
    %{
      before: before_cursor,
      last: size
    }
  end

  defp map_to_flop(%{"size" => size}) do
    %{
      first: size
    }
  end

  defp map_to_flop(page) do
    page
  end
end
