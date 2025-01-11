defmodule RunaWeb.ComponentCase do
  @moduledoc """
  A case template for testing stateless component.
  """
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint RunaWeb.Endpoint

      import Phoenix.LiveViewTest
      import LiveIsolatedComponent

      use Repatch.ExUnit

      @spec wrap_component(module(), atom(), map()) ::
              {:ok, map()} | {:error, map()}
      def wrap_component(module, function, assigns) do
        assigns =
          Map.merge(assigns, %{__module__: module, __function__: function})

        {_, component, _, _} = create_component()

        live_isolated_component(component, assigns)
      end

      defp create_component() do
        defmodule :"Elixir.LiveComponentWrapper_#{:erlang.unique_integer([:positive])}" do
          use Phoenix.LiveComponent

          def render(var!(assigns)) do
            ~H"""
            <div>
              {Phoenix.LiveView.TagEngine.component(
                Function.capture(var!(assigns).__module__, var!(assigns).__function__, 1),
                Map.drop(var!(assigns), [
                  :socket,
                  :__changed__,
                  :myself,
                  :flash,
                  :__module__,
                  :__function__
                ]),
                {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
              )}
            </div>
            """
          end
        end
      end
    end
  end
end
