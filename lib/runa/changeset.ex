defmodule Runa.Changeset do
  @moduledoc """
  A modaule contains helper functions for working with Ecto changesets.
  """

  @doc """
  Validates a list field within a changeset by applying a callback function to each element.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.Nesting
  @spec validate_list(
          Ecto.Changeset.t(),
          atom(),
          (Ecto.Changeset.t() -> Ecto.Changeset.t())
        ) :: Ecto.Changeset.t()
  def validate_list(%Ecto.Changeset{} = changeset, field, callback) do
    changeset = Ecto.Changeset.change(changeset)
    {:array, element_type} = changeset.types[field]

    Ecto.Changeset.validate_change(changeset, field, fn _, values ->
      Enum.flat_map(values, fn value ->
        result =
          {%{}, %{value: element_type}}
          |> Ecto.Changeset.cast(%{value: value}, [:value])
          |> callback.()
          |> Ecto.Changeset.apply_action(:insert)

        case result do
          {:ok, _} ->
            []

          {:error, %{errors: errors}} ->
            {message, meta} = errors[:value]
            [{field, {"#{value}: #{message}", meta}}]
        end
      end)
    end)
  end
end
