defmodule RunaWeb.JSONAPI.Headers do
  @moduledoc false

  def accept,
    do: "application/vnd.api+json"

  def content_type,
    do: "application/vnd.api+json"

  def api_key,
    do: "x-api-key"
end
