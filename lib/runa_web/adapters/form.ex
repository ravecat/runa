defmodule RunaWeb.Adapters.Form do
  @moduledoc """
  Adapters for Phoenix.HTML.Form to Svelte superforms https://superforms.rocks/ compatible JSON.
  """

  import RunaWeb.Adapters.Error

  defimpl Jason.Encoder, for: Phoenix.HTML.Form do
    def encode(form, opts) do
      Jason.Encoder.encode(
        %{
          id: form.id,
          name: form.name,
          data: form.data,
          errors: traverse_errors(form),
          posted: true,
          valid: form.errors == []
        },
        opts
      )
    end

    defp traverse_errors(%Phoenix.HTML.Form{errors: errors}) do
      for {field, error} <- errors, into: %{} do
        {field, [translate_error(error)]}
      end
    end
  end
end
