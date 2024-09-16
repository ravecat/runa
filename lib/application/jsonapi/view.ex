defmodule RunaWeb.JSONAPI.View do
  @moduledoc """
  JSONAPI view module

  This module is used to generate JSONAPI responses for resources
  """
  defmacro __using__(serializer: serializer) do
    quote do
      import JSONAPI.Serializer

      def index(%{data: data, conn: conn} = args) do
        unquote(serializer)
        |> serialize(data, conn)
      end

      def show(%{data: data, conn: conn}) do
        unquote(serializer)
        |> serialize(data, conn)
      end

      def create(%{data: data, conn: conn}) do
        unquote(serializer)
        |> serialize(data, conn)
      end

      def update(%{data: data, conn: conn}) do
        unquote(serializer)
        |> serialize(data, conn)
      end

      def delete(%{conn: conn}) do
        %{}
      end
    end
  end
end
