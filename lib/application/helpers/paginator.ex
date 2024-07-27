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
        view.url_for_pagination(data, conn, %{
          number: number,
          size: size
        }),
      last:
        view.url_for_pagination(data, conn, %{
          number: total,
          size: size
        }),
      next:
        if(number < total,
          do:
            view.url_for_pagination(data, conn, %{
              number: number + 1,
              size: size
            })
        ),
      prev:
        if(number > 1,
          do:
            view.url_for_pagination(data, conn, %{
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
      first: view.url_for_pagination(data, conn, %{offset: 0, limit: limit}),
      last:
        view.url_for_pagination(data, conn, %{
          offset: total,
          limit: limit
        }),
      next:
        if(offset + limit < total,
          do:
            view.url_for_pagination(data, conn, %{
              offset: offset + limit,
              limit: limit
            })
        ),
      prev:
        if(offset > 0,
          do:
            view.url_for_pagination(data, conn, %{
              offset: offset - limit,
              limit: limit
            })
        )
    }
  end

  def paginate(_data, _view, _conn, _page, _options) do
    %{}
  end
end
