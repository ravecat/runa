defmodule Runa.Repo.Helpers do
  alias Runa.Repo

  import Ecto.Query

  @doc """
  Ensures an entry exists for given fields values. If not, creates one with the given defaults.
  """
  def ensure(queryable, clauses, defaults \\ %{})
      when is_list(clauses) and is_map(defaults) do
    query =
      Enum.reduce(clauses, from(e in queryable), fn {field, value}, acc ->
        from e in acc, where: field(e, ^field) == ^value
      end)

    case Repo.all(query) do
      [] ->
        create_entry(queryable, defaults)

      entries ->
        {:ok, entries}
    end
  end

  defp create_entry(schema, attrs) do
    struct = struct!(schema, attrs)
    changeset = schema.changeset(struct, attrs)

    case Repo.insert(changeset) do
      {:ok, entry} -> {:ok, [entry]}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
