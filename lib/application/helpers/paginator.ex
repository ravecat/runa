defmodule RunaWeb.Paginator do
  @moduledoc """
  Page based pagination strategy
  """

  @behaviour JSONAPI.Paginator

  @impl true
  def paginate(
        data,
        view,
        %{
          assigns: %{
            page: %Flop.Meta{} = meta,
            jsonapi_query: %{page: %{"size" => _, "number" => _}}
          }
        } = conn,
        _,
        _
      ) do
    number = meta.current_page
    size = meta.page_size
    total = meta.total_pages

    %{
      first:
        prepare_url(data, view, conn, %{
          number: number,
          size: size
        }),
      last:
        prepare_url(data, view, conn, %{
          number: total,
          size: size
        }),
      next:
        if(number < total,
          do:
            prepare_url(data, view, conn, %{
              number: number + 1,
              size: size
            })
        ),
      prev:
        if(number > 1,
          do:
            prepare_url(data, view, conn, %{
              number: number - 1,
              size: size
            })
        )
    }
  end

  @impl true
  def paginate(
        data,
        view,
        %{
          assigns: %{
            page: %Flop.Meta{} = meta,
            jsonapi_query: %{page: %{"offset" => _, "limit" => _}}
          }
        } = conn,
        _,
        _
      ) do
    offset = meta.current_offset
    limit = meta.page_size
    total = meta.total_pages

    %{
      first: prepare_url(data, view, conn, %{offset: 0, limit: limit}),
      last:
        prepare_url(data, view, conn, %{
          offset: total,
          limit: limit
        }),
      next:
        if(offset + limit < total,
          do:
            prepare_url(data, view, conn, %{
              offset: offset + limit,
              limit: limit
            })
        ),
      prev:
        if(offset > 0,
          do:
            prepare_url(data, view, conn, %{
              offset: offset - limit,
              limit: limit
            })
        )
    }
  end

  @impl true
  def paginate(
        data,
        view,
        %{
          assigns: %{
            page:
              %Flop.Meta{
                end_cursor: end_cursor,
                start_cursor: start_cursor,
                page_size: size
              } = meta
          }
        } = conn,
        _,
        _
      )
      when not is_nil(start_cursor) and not is_nil(end_cursor) do
    %{
      next:
        if(meta.has_next_page?,
          do:
            prepare_url(data, view, conn, %{
              after: end_cursor,
              size: size
            })
        ),
      prev:
        if(meta.has_previous_page?,
          do:
            prepare_url(data, view, conn, %{
              before: start_cursor,
              size: size
            })
        ),
      first:
        prepare_url(data, view, conn, %{
          size: size
        }),
      last:
        unless(
          meta.has_next_page?,
          do:
            prepare_url(data, view, conn, %{
              before: end_cursor,
              size: size
            })
        )
    }
  end

  def paginate(_data, _view, _conn, _page, _options) do
    %{}
  end

  defp prepare_url(data, view, conn, query) do
    view.url_for_pagination(data, conn, query)
    |> URI.decode()
  end
end
