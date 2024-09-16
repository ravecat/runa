defmodule RunaWeb.JSONAPI.View do
  @moduledoc """
  JSONAPI view module

  This module is used to generate JSONAPI responses for resources
  """
  defmacro __using__(serializer: serializer) do
    quote do
      import JSONAPI.Serializer
      import Pathex

      def render(_, %{
            data: data,
            conn: %{path_params: %{"relationship" => relationship}} = conn
          }) do
        relationship_path =
          path(:data / :relationships / String.to_atom(relationship))

        unquote(serializer)
        |> serialize(data, conn)
        |> get(relationship_path)
      end

      def render(_, %{data: data, conn: conn}) do
        unquote(serializer)
        |> serialize(data, conn)
      end

      @dialyzer {:nowarn_function, {:render, 2}}
      def render(_, %{conn: conn}) do
        %{}
      end
    end
  end
end
