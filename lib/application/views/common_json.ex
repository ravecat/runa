defmodule RunaWeb.CommonJSON do
  defmacro __using__(serializer: serializer) do
    quote do
      import JSONAPI.Serializer

      def index(%{data: data, conn: conn}) do
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
