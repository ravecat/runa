defmodule JSONAPI.QueryParams do
  @moduledoc """
  Defines structure for query params according to JSON:API specification
  """

  @type sort :: [{:desc | :asc, atom()}] | []
  @type page ::
          %{required(:limit) => String.t(), required(:offset) => String.t()}
          | %{required(:size) => String.t(), optional(:number) => String.t()}
          | %{required(:size) => String.t(), optional(:after) => String.t()}
          | %{required(:size) => String.t(), optional(:before) => String.t()}
          | %{}
  @type filter :: [{atom(), String.t()}] | []
end
