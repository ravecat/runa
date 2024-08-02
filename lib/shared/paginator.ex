defmodule Runa.Paginator do
  @moduledoc """
  Paginator module for offset, page and cursor based pagination
  """
  @type option ::
          Flop.option()
          | {:sort, keyword() | nil}
          | {:filter, keyword() | nil}
          | {:page, map()}
          | {:query, Ecto.Query.t()}

  @spec paginate([option()]) ::
          {:ok, {[any], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  def paginate(opts \\ []) do
    sort = Keyword.get(opts, :sort, [])
    filter = Keyword.get(opts, :filter, [])
    page = Keyword.get(opts, :page, %{})
    module = Keyword.get(opts, :for, nil)
    query = Keyword.get(opts, :query, nil)

    {order_direction, order_by} = Enum.unzip(sort)

    paginate_opts = %{
      order_by: order_by,
      order_direction: order_direction,
      filters: filter
    }

    do_paginate(query, page, paginate_opts, module)
  end

  @spec do_paginate(Ecto.Query.t(), %{}, map(), module()) ::
          {:ok, {[any], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  defp do_paginate(query, %{"number" => number, "size" => size}, opts, module) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        page: number,
        page_size: size
      }),
      for: module
    )
  end

  defp do_paginate(query, %{"offset" => offset, "limit" => limit}, opts, module) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        offset: offset,
        limit: limit
      }),
      for: module
    )
  end

  defp do_paginate(
         query,
         %{"after" => after_cursor, "size" => size},
         opts,
         module
       ) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        after: after_cursor,
        first: size
      }),
      for: module
    )
  end

  defp do_paginate(
         query,
         %{"before" => before_cursor, "size" => size},
         opts,
         module
       ) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        before: before_cursor,
        last: size
      }),
      for: module
    )
  end

  defp do_paginate(query, %{"size" => size}, opts, module) do
    Flop.validate_and_run(
      query,
      Map.merge(opts, %{
        first: size
      }),
      for: module
    )
  end

  @spec do_paginate(Ecto.Query.t(), %{}, map(), module()) ::
          {:ok, {[any], Flop.Meta.t()}} | {:error, Flop.Meta.t()}
  defp do_paginate(_query, _page, _opts, _module) do
    {:error, :invalid_pagination_params}
  end
end
