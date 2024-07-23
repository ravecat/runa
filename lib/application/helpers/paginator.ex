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
            page: %{
              total_pages: total_pages,
              number: number,
              size: size
            }
          }
        } = conn,
        _,
        _
      ) do
    %{
      first: view.url_for_pagination(data, conn, %{number: 1, size: size}),
      last:
        view.url_for_pagination(data, conn, %{number: total_pages, size: size}),
      next: next_link(data, view, conn, number, size, total_pages),
      prev: previous_link(data, view, conn, number, size)
    }
  end

  def paginate(_data, _view, _conn, _page, _options) do
    %{}
  end

  defp next_link(data, view, conn, page, size, total_pages)
       when page < total_pages,
       do: view.url_for_pagination(data, conn, %{size: size, page: page + 1})

  defp next_link(_data, _view, _conn, _page, _size, _total_pages),
    do: nil

  defp previous_link(data, view, conn, page, size)
       when page > 1,
       do: view.url_for_pagination(data, conn, %{size: size, page: page - 1})

  defp previous_link(_data, _view, _conn, _page, _size),
    do: nil
end
